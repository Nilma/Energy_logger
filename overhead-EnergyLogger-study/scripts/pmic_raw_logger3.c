// pmic_raw_logger.c
// Logs raw PMIC readings from `vcgencmd pmic_read_adc`.
// Format: one row per snapshot (sample).
// CSV columns: duration_s,active,<channel1>,<channel2>,...
//   duration_s : seconds since logger start (monotonic)
//   active     : 1 while workload runs, 0 otherwise (before/after)
//   channel N  : numeric value (A for *current, V for *volt), unit not included.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>
#include <math.h>

#define LINE_BUF   512
#define MAX_CH     64
#define NAME_LEN   128

typedef struct {
    char name[NAME_LEN];
    char type;  // 'I' or 'V'
} Channel;

static volatile sig_atomic_t keep_running = 1;
static volatile sig_atomic_t active_flag  = 0;

static void handle_stop(int sig) {
    (void)sig;
    keep_running = 0;
}

static void handle_active_on(int sig) {
    (void)sig;
    active_flag = 1;
}

static void handle_active_off(int sig) {
    (void)sig;
    active_flag = 0;
}

static double now_monotonic_s(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

// trim leading + trailing whitespace (in-place)
static void trim(char *s) {
    // leading
    size_t start = 0;
    while (s[start] == ' ' || s[start] == '\t' ||
           s[start] == '\n' || s[start] == '\r') {
        start++;
    }
    if (start > 0) {
        memmove(s, s + start, strlen(s + start) + 1);
    }
    // trailing
    size_t len = strlen(s);
    while (len > 0) {
        char c = s[len - 1];
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
            s[--len] = '\0';
        } else {
            break;
        }
    }
}

// Discover available channels once
static int discover_channels(Channel *channels, int max_ch) {
    FILE *fp = popen("vcgencmd pmic_read_adc", "r");
    if (!fp) {
        perror("popen vcgencmd (discover)");
        return 0;
    }

    char line[LINE_BUF];
    int n = 0;

    while (fgets(line, sizeof(line), fp)) {
        int is_current = strstr(line, "current") != NULL;
        int is_volt    = strstr(line, "volt")    != NULL;
        if (!is_current && !is_volt) continue;

        char *eq = strchr(line, '=');
        if (!eq) continue;

        char name[NAME_LEN];
        size_t name_len = (size_t)(eq - line);
        if (name_len >= sizeof(name)) name_len = sizeof(name) - 1;
        memcpy(name, line, name_len);
        name[name_len] = '\0';
        trim(name);

        int exists = 0;
        for (int i = 0; i < n; i++) {
            if (strcmp(channels[i].name, name) == 0) {
                exists = 1;
                break;
            }
        }
        if (exists) continue;

        if (n >= max_ch) {
            fprintf(stderr, "Warning: too many channels, truncating.\n");
            break;
        }

        strncpy(channels[n].name, name, NAME_LEN - 1);
        channels[n].name[NAME_LEN - 1] = '\0';
        channels[n].type = is_current ? 'I' : 'V';
        n++;
    }

    pclose(fp);
    return n;
}

// Read one snapshot into values[], NAN if missing
static void read_snapshot(const Channel *channels, int n_channels,
                          double *values) {
    for (int i = 0; i < n_channels; i++) {
        values[i] = NAN;
    }

    FILE *fp = popen("vcgencmd pmic_read_adc", "r");
    if (!fp) {
        perror("popen vcgencmd (snapshot)");
        return;
    }

    char line[LINE_BUF];

    while (fgets(line, sizeof(line), fp)) {
        int is_current = strstr(line, "current") != NULL;
        int is_volt    = strstr(line, "volt")    != NULL;
        if (!is_current && !is_volt) continue;

        char *eq = strchr(line, '=');
        if (!eq) continue;

        char name[NAME_LEN];
        size_t name_len = (size_t)(eq - line);
        if (name_len >= sizeof(name)) name_len = sizeof(name) - 1;
        memcpy(name, line, name_len);
        name[name_len] = '\0';
        trim(name);

        char *num_start = eq + 1;
        char *endptr;
        double value = strtod(num_start, &endptr);

        for (int i = 0; i < n_channels; i++) {
            if (strcmp(channels[i].name, name) == 0) {
                values[i] = value;
                break;
            }
        }
    }

    pclose(fp);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr,
                "Usage: %s <sample_period_seconds> <output.csv>\n",
                argv[0]);
        return 1;
    }

    double period = atof(argv[1]);
    if (period <= 0) {
        fprintf(stderr, "Period must be > 0\n");
        return 1;
    }

    const char *out_path = argv[2];
    FILE *csv = fopen(out_path, "w");
    if (!csv) {
        perror("fopen");
        return 1;
    }

    // install signal handlers ASAP
    signal(SIGTERM, handle_stop);
    signal(SIGINT,  handle_stop);
    signal(SIGUSR1, handle_active_on);
    signal(SIGUSR2, handle_active_off);

    Channel channels[MAX_CH];
    int n_channels = discover_channels(channels, MAX_CH);
    if (n_channels <= 0) {
        fprintf(stderr, "No PMIC channels discovered. Exiting.\n");
        fclose(csv);
        return 1;
    }

    // header: duration_s,active,<channels...>
    fprintf(csv, "duration_s,active");
    for (int i = 0; i < n_channels; i++) {
        fprintf(csv, ",%s", channels[i].name);
    }
    fprintf(csv, "\n");

    double t0     = now_monotonic_s();
    double t_next = t0;
    double values[MAX_CH];

    while (keep_running) {
        double t_now = now_monotonic_s();
        double t_rel = t_now - t0;

        read_snapshot(channels, n_channels, values);

        // row: duration_s,active_flag,values...
        fprintf(csv, "%.6f,%d", t_rel, active_flag ? 1 : 0);
        for (int i = 0; i < n_channels; i++) {
            if (isnan(values[i])) {
                fprintf(csv, ",");
            } else {
                fprintf(csv, ",%.6f", values[i]);
            }
        }
        fprintf(csv, "\n");

        t_next += period;
        double t_after = now_monotonic_s();
        double sleep_s = t_next - t_after;
        if (sleep_s > 0) {
            struct timespec req;
            req.tv_sec  = (time_t)sleep_s;
            req.tv_nsec = (long)((sleep_s - req.tv_sec) * 1e9);
            nanosleep(&req, NULL);
        } else {
            t_next = now_monotonic_s();
        }
    }

    fclose(csv);
    return 0;
}
