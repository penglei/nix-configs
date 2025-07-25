import json
import os
import subprocess
import time
from pathlib import Path
from typing import Any

from kitty.boss import Boss
from kitty.window import Window


def ensure_state_filepath():
    file_path = Path(os.path.expanduser("~/.local/state/kitty/data.json"))
    if not file_path.exists():
        file_path.parent.mkdir(parents=True, exist_ok=True)
    return file_path


def on_load(boss, data):
    ensure_state_filepath()
    # file_path = os.path.expanduser("~/.local/state/kitty")
    # os.makedirs(file_path)


def on_cmd_startstop(boss, window, data):
    output_tabs(boss, window, data)


def on_title_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    output_tabs(boss, window, data)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    output_tabs(boss, window, data)


def output_tabs(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    file_path = ensure_state_filepath()

    data = {}

    os_win_tab_counter = {}
    window_tab_infos = []
    curr_os_window_id = -1
    curr_tab_detail = {}
    curr_tab_index = 0
    for tab in boss.all_tabs:
        count = os_win_tab_counter.get(tab.os_window_id) or 0
        count += 1
        os_win_tab_counter[tab.os_window_id] = count

        if window.tab_id == tab.id:
            curr_tab_index = count
            curr_os_window_id = tab.os_window_id

            if tab.active_window != None:
                tabwin = tab.active_window.as_dict()
                foreground_processes = tabwin["foreground_processes"]
                if len(foreground_processes) > 0:
                    curr_tab_detail["process"] = foreground_processes[0]
                curr_tab_detail["env"] = {
                    "HOME": (tabwin.get("env") or {}).get("HOME") or ""
                }

        tab_info = {
            "id": tab.id,
            "name": tab.name,
            "os_window_id": tab.os_window_id,
        }
        if tab.active_window != None:
            tab_info["win"] = tab.active_window.as_dict()
        window_tab_infos.append(tab_info)

    # data["window_tab_infos"] = window_tab_infos

    data["tab_id"] = window.tab_id
    data["curr_num_tabs"] = os_win_tab_counter.get(curr_os_window_id) or 0  # tabs个数
    data["curr_tab_index"] = curr_tab_index
    cwd = (curr_tab_detail.get("process") or {}).get("cwd") or ""
    home_dir = (curr_tab_detail.get("env") or {}).get("HOME") or ""
    if home_dir != "":
        if cwd.startswith(home_dir):
            cwd = "~" + cwd[len(home_dir) :]
    data["curr_tab_cwd"] = cwd
    data["curr_tab_detail"] = curr_tab_detail

    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    subprocess.run(["sketchybar", "--trigger", "title_change"])
