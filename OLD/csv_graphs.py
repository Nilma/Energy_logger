#!/usr/bin/env python3
"""
csv_graphs.py — Load a CSV and generate common graphs with minimal fuss.

USAGE (examples):
  python3 csv_graphs.py --csv energy_log_2.csv
  python3 csv_graphs.py --csv data.csv --sep ';' --decimal ','
  python3 csv_graphs.py --csv data.csv --time-col timestamp --y-cols power_w,current_a
  python3 csv_graphs.py --csv data.csv --save-dir ./plots --no-show
"""

import argparse
from pathlib import Path
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# ------------------ Helpers ------------------

def smart_read_csv(path, sep=',', decimal='.', encoding=None):
    """Read CSV and auto-detect common date columns."""
    kw = {"sep": sep, "decimal": decimal}
    if encoding:
        kw["encoding"] = encoding
    df = pd.read_csv(path, **kw)
    # Try to parse likely date/time columns
    for col in df.columns:
        if df[col].dtype == object:
            try:
                s = pd.to_datetime(df[col], errors='raise', utc=False)
                ok_ratio = s.notna().mean() if len(s) else 0
                if ok_ratio >= 0.8:
                    df[col] = s
            except Exception:
                pass
    return df

def numeric_cols(df):
    return df.select_dtypes(include=[np.number]).columns.tolist()

def datetime_cols(df):
    return df.select_dtypes(include=["datetime64[ns]", "datetimetz"]).columns.tolist()

def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)

def maybe_save(fig, save_dir: Path, title_stub: str):
    if save_dir is None:
        return
    ensure_dir(save_dir)
    safe = "".join(c if c.isalnum() or c in "-_." else "_" for c in title_stub)
    out = save_dir / f"{safe}.png"
    fig.savefig(out, bbox_inches="tight", dpi=150)
    print(f"Saved: {out}")

# ------------------ Plotters ------------------

def line_over_time(df, time_col=None, y_cols=None, title='Line over time', save_dir=None, show=True):
    if time_col is None:
        dcols = datetime_cols(df)
        if not dcols:
            raise ValueError("No datetime-like column found. Specify --time-col.")
        time_col = dcols[0]
    if y_cols is None:
        y_cols = numeric_cols(df)
    if not y_cols:
        raise ValueError("No numeric columns to plot.")
    for col in y_cols:
        fig = plt.figure()
        df.plot(x=time_col, y=col, kind='line', legend=False)
        plt.title(f"{title}: {col}")
        plt.xlabel(time_col)
        plt.ylabel(col)
        plt.tight_layout()
        maybe_save(fig, save_dir, f"line_{col}_vs_{time_col}")
        if show:
            plt.show()
        else:
            plt.close(fig)

def bar_top_n(df, by_col, value_col, n=10, ascending=False, title='Top N', save_dir=None, show=True):
    tmp = df[[by_col, value_col]].dropna()
    agg = tmp.groupby(by_col, dropna=False)[value_col].sum().sort_values(ascending=ascending)
    top = agg.head(n)
    fig = plt.figure()
    top.plot(kind='bar')
    plt.title(f"{title}: {value_col} by {by_col}")
    plt.xlabel(by_col)
    plt.ylabel(value_col)
    plt.tight_layout()
    maybe_save(fig, save_dir, f"bar_top_{n}_{value_col}_by_{by_col}")
    if show:
        plt.show()
    else:
        plt.close(fig)

def histograms(df, bins=30, save_dir=None, show=True):
    nums = numeric_cols(df)
    if not nums:
        raise ValueError("No numeric columns found for histograms.")
    for col in nums:
        fig = plt.figure()
        df[col].dropna().plot(kind='hist', bins=bins)
        plt.title(f"Histogram: {col}")
        plt.xlabel(col)
        plt.tight_layout()
        maybe_save(fig, save_dir, f"hist_{col}")
        if show:
            plt.show()
        else:
            plt.close(fig)

def scatter(df, x, y, title=None, save_dir=None, show=True):
    fig = plt.figure()
    df.plot(kind='scatter', x=x, y=y)
    plt.title(title or f"Scatter: {x} vs {y}")
    plt.tight_layout()
    maybe_save(fig, save_dir, f"scatter_{x}_vs_{y}")
    if show:
        plt.show()
    else:
        plt.close(fig)

def correlation_heatmap(df, save_dir=None, show=True):
    num = df[numeric_cols(df)]
    if num.empty or num.shape[1] < 2:
        raise ValueError("Need at least two numeric columns for a correlation heatmap.")
    corr = num.corr(numeric_only=True)
    fig = plt.figure(figsize=(6,5))
    plt.imshow(corr, interpolation='nearest')
    plt.xticks(range(len(corr.columns)), corr.columns, rotation=90)
    plt.yticks(range(len(corr.columns)), corr.columns)
    plt.colorbar()
    plt.title('Correlation heatmap')
    plt.tight_layout()
    maybe_save(fig, save_dir, "correlation_heatmap")
    if show:
        plt.show()
    else:
        plt.close(fig)

# ------------------ Main ------------------

def main():
    ap = argparse.ArgumentParser(description="Generate graphs from a CSV quickly.")
    ap.add_argument("--csv", required=True, help="Path to CSV file")
    ap.add_argument("--sep", default=",", help="CSV separator (default ',')")
    ap.add_argument("--decimal", default=".", help="Decimal char (default '.')")
    ap.add_argument("--encoding", default=None, help="CSV encoding (e.g., 'utf-8', 'latin-1')")
    ap.add_argument("--time-col", default=None, help="Name of datetime column to use for time-based plots")
    ap.add_argument("--y-cols", default=None, help="Comma-separated numeric columns for line plot")
    ap.add_argument("--top-by", default=None, help="Categorical column for top-N bar chart")
    ap.add_argument("--top-val", default=None, help="Numeric column for top-N bar chart")
    ap.add_argument("--top-n", type=int, default=10, help="N for top-N bar chart (default 10)")
    ap.add_argument("--bins", type=int, default=30, help="Bins for histograms")
    ap.add_argument("--scatter-x", default=None, help="X column for scatter")
    ap.add_argument("--scatter-y", default=None, help="Y column for scatter")
    ap.add_argument("--save-dir", default=None, help="Directory to save PNGs (no saving if omitted)")
    ap.add_argument("--no-show", action="store_true", help="Do not display plots interactively")
    ap.add_argument("--skip-line", action="store_true", help="Skip line-over-time plots")
    ap.add_argument("--skip-hist", action="store_true", help="Skip histograms")
    ap.add_argument("--skip-heatmap", action="store_true", help="Skip correlation heatmap")
    args = ap.parse_args()

    csv_path = Path(args.csv)
    if not csv_path.exists():
        print(f"ERROR: CSV file not found: {csv_path}", file=sys.stderr)
        sys.exit(1)

    df = smart_read_csv(csv_path, sep=args.sep, decimal=args.decimal, encoding=args.encoding)
    print(f"Loaded: {csv_path} | Rows: {len(df)} | Columns: {len(df.columns)}")
    print("Columns:", df.columns.tolist())

    save_dir = Path(args.save_dir) if args.save_dir else None
    show = not args.no_show

    if not args.skip_line:
        try:
            y_cols = [s.strip() for s in args.y_cols.split(",")] if args.y_cols else None
            line_over_time(df, time_col=args.time_col, y_cols=y_cols, save_dir=save_dir, show=show)
        except Exception as e:
            print(f"[line_over_time] skipped: {e}")

    if not args.skip_hist:
        try:
            histograms(df, bins=args.bins, save_dir=save_dir, show=show)
        except Exception as e:
            print(f"[histograms] skipped: {e}")

    if args.scatter_x and args.scatter_y:
        try:
            scatter(df, x=args.scatter_x, y=args.scatter_y, save_dir=save_dir, show=show)
        except Exception as e:
            print(f"[scatter] skipped: {e}")

    if args.top_by and args.top_val:
        try:
            bar_top_n(df, by_col=args.top_by, value_col=args.top_val, n=args.top_n, save_dir=save_dir, show=show)
        except Exception as e:
            print(f"[bar_top_n] skipped: {e}")

    if not args.skip_heatmap:
        try:
            correlation_heatmap(df, save_dir=save_dir, show=show)
        except Exception as e:
            print(f"[correlation_heatmap] skipped: {e}")

if __name__ == "__main__":
    main()