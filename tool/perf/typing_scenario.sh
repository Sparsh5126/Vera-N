#!/usr/bin/env bash
# Typing performance scenario for Vera N (CLAUDE.md §8 "measure before and
# after"). Needs the measurement build installed (separate app, own storage):
#   flutter build apk --profile --android-project-arg=vera.perf=true
#   adb install -r build/app/outputs/flutter-apk/app-profile.apk
#
# Usage: typing_scenario.sh SERIAL plain|rich|long RUNS
# long: a ~120-line note (checklists, bullets, bold, plain lines), since
# editor work per keystroke grows with the note's length.
# Prints one "VeraN frames:" line per run, covering only steady typing:
# the note is set up, the app is sent Home (which logs and resets the
# frame stats), brought back, typed into for 15 bursts, then sent Home.
set -u
export MSYS_NO_PATHCONV=1
ADB="${ADB:-adb} -s $1"
KIND=$2
RUNS=${3:-3}
PKG=io.github.sparsh5126.veran.perf
ACT=com.example.vera_n.MainActivity

type_text() { timeout 10 $ADB shell "input text '$1'"; }
enter() { timeout 10 $ADB shell input keyevent KEYCODE_ENTER; }

for run in $(seq 1 "$RUNS"); do
  timeout 10 $ADB shell am force-stop $PKG; sleep 1
  timeout 10 $ADB shell am start -a com.example.vera_n.NEW_NOTE -n $PKG/$ACT >/dev/null; sleep 4
  type_text 'Typing%stest'; enter
  if [ "$KIND" = rich ]; then
    # A checklist (Enter continues it), then bold words.
    type_text '-%s[%s]%smilk'; enter
    type_text 'eggs'; enter
    type_text 'bread'; enter; enter
    type_text '**Plan**%sfor%sthe%sweek'; enter
    type_text 'see%sthe%s**big**%sidea%sbelow'; enter
  fi
  if [ "$KIND" = long ]; then
    for j in $(seq 1 30); do
      type_text "-%s[%s]%sitem%s$j%swith%s**bold**%swords"; enter; enter
      type_text "-%sbullet%s$j"; enter; enter
      type_text "plain%sline%s$j%sabout%sthe%sweek%sand%sthe%splan"; enter
      type_text "another%sordinary%sline%s$j"; enter
    done
  fi
  # Send Home: logs and resets the setup frames.
  timeout 10 $ADB shell input keyevent KEYCODE_HOME; sleep 2
  timeout 10 $ADB logcat -c
  timeout 10 $ADB shell am start -n $PKG/$ACT >/dev/null; sleep 2
  for i in $(seq 1 15); do
    type_text 'the%squick%sbrown%sfox%sjumps%sover%sthe%slazy%sdog%s'
    sleep 0.3
  done
  timeout 10 $ADB shell input keyevent KEYCODE_HOME; sleep 2
  echo "$KIND run $run: $(timeout 10 $ADB logcat -d -s flutter:I | grep -oE 'VeraN frames: .*' | tail -1)"
done
timeout 10 $ADB shell am force-stop $PKG
