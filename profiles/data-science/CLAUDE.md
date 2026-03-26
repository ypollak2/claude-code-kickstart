# Project Instructions

## Stack
Python 3.12, pandas, scikit-learn, PyTorch, Jupyter, DVC

## Commands
- `jupyter lab` — start Jupyter Lab
- `pytest -v` — run tests
- `dvc repro` — reproduce the pipeline
- `dvc push` — push data to remote storage
- `ruff check .` — lint
- `mypy .` — type check

## Architecture
- `notebooks/` — exploratory Jupyter notebooks (numbered: 01_, 02_, ...)
- `src/` — production-ready code
  - `data/` — data loading and preprocessing
  - `features/` — feature engineering
  - `models/` — model definitions and training
  - `evaluation/` — metrics and evaluation
- `data/` — data directory (gitignored, tracked by DVC)
  - `raw/` — original immutable data
  - `processed/` — cleaned and transformed
  - `models/` — trained model artifacts
- `configs/` — experiment configurations (YAML)
- `tests/` — unit tests for src/

## Critical Constraints
- Never modify raw data — create processed versions instead
- Always set random seeds for reproducibility (numpy, torch, sklearn)
- Use `.copy()` to avoid pandas SettingWithCopyWarning
- Log all experiments with parameters, metrics, and artifacts
- Every notebook must be reproducible top-to-bottom (Restart & Run All)
- State null hypothesis before running statistical tests
- Report confidence intervals, not just p-values
