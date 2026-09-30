#!/usr/bin/env python3
"""Reproduce the four route-selection calls in Chapter 5 (no simulator needed)."""
import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name, relative_path):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative_path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


for name, path, method in [
    ("lesson_q3", "source/Q3/q3_local_solver.py", "_choose"),
    ("lesson_q4", "source/Q4/q4_local_solver.py", "_choose_insert"),
]:
    module = load(name, path)
    strategy = module.Strategy(api=None)
    strategy.p = (0.0, 0.0)
    strategy.tracks[1].status = "FOUND"
    strategy.tracks[1].center = (400.0, 300.0)
    strategy.tracks[1].radius = 80.0
    strategy.tracks[2].status = "FOUND"
    strategy.tracks[2].center = (800.0, -600.0)
    strategy.tracks[2].radius = 10.0
    choose = getattr(strategy, method)
    next_site = (1000.0, 0.0)

    answers = [choose(next_site)]
    strategy.tracks[1].status = "CLEARED"
    strategy.p = (400.0, 300.0)
    answers.append(choose(next_site))
    strategy.p = next_site
    answers.append(choose(None))
    strategy.tracks[2].status = "CLEARED"
    answers.append(choose(None))
    print(name, answers)
