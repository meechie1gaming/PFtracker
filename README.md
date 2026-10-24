# PFtracker

Windower 4 addon for FFXI. Posts Peculiar Foes info to party chat: which foe is next, where it is, the fastest way there, and a reminder to set the RoE objective before popping.

It can also post the next foe automatically when a Peculiar Foes objective completes.

**Author:** Meechie
**Version:** 0.5

## Install

1. Create `Windower/addons/PFtracker/`
2. Put `PFtracker.lua` in that folder
3. In game: `//lua load pftracker`

To load it every time, add `lua load pftracker` to `Windower/scripts/init.txt`.

## Commands

| Command | What it does |
| --- | --- |
| `//pf <1-15>` | Posts that foe to party chat |
| `//pf next` | Posts the next foe that isn't done yet |
| `//pf list` | Shows all 15 in your local chat log with done foes grayed out, plus whether auto is on |
| `//pf auto` | Turns auto-next on or off |
| `//pf style` | Switches party text between fancy and plain |
| `//pf reset` | Clears done marks |
| `//pf debug` | Shows detection output in your log |

`//pf` with no command shows the help list. `//pftracker` works in place of `//pf`.

## Party Chat Output

Fancy style (default):

```
◆◇◆ Peculiar Foe 1/15 ◆◇◆
★ Awoken Hildesvini 【Wajaom Woodlands (H-13)】
→ Unity warp (CL135) to Wajaom Woodlands, ride south
※ RoE: set Peculiar Foes I (Quests 4) before popping!
```

Plain style:

```
=== Peculiar Foe 1/15 ===
>> Awoken Hildesvini [Wajaom Woodlands (H-13)]
-> Unity warp (CL135) to Wajaom Woodlands, ride south
!! RoE: set Peculiar Foes I (Quests 4) before popping!
```

The fancy symbols come from the Japanese character set, which the FFXI client shows for everyone. If they come out garbled, switch with `//pf style`.

Lines go out 1.5 seconds apart so chat doesn't flood.

## How It Works

The addon watches for this game message:

```
You have completed the following Records of Eminence objective: Peculiar Foes IX (M).
```

When it sees one, it marks that foe done and posts "<foe> done" in your log. With auto on, it waits 3 seconds and posts the next foe that isn't done yet with a "Next Up:" header. After XV it goes back to I and skips anything already done. When all 15 are done it posts "All Peculiar Foes down!"

- It only fires when the RoE actually completes. If you forget to set the objective, it won't move on, so you can pop the foe again.
- It doesn't matter who gets the killing blow.
- XV completes after all three (Angantyr, Hjorvarth, Hrani) are dead.
- You don't need to call `//pf <n>` first.
- Foes are marked done even with auto off, so `//pf list` tracks progress either way.

## Multiboxing

Auto starts off every time the addon loads. Turn it on for one character only. If auto is on for every character, each one posts.

## Foe List

| # | RoE | Foe | Location | Fastest Route |
| --- | --- | --- | --- | --- |
| 1 | I | Awoken Hildesvini | Wajaom Woodlands (H-13) | Unity warp (CL135) to Wajaom Woodlands, ride south |
| 2 | II | Awoken Mokkuralfi | Mount Zhayolm (I-10) | Voidwatch warp to Mount Zhayolm |
| 3 | III | Awoken Vampyr Jarl | Caedarva Mire, Hediva Isle (I-6) | Unity warp (CL135) to Caedarva Mire, ride north |
| 4 | IV | Awoken Gorgimera | Beaucedine Glacier (K-6) | HP to Fei'Yin, cast Escape (alt: Unity CL128 to Fei'Yin) |
| 5 | V | Awoken Ariri Samariri | Palborough Mines map 3 (G-10) | HP #1 Palborough Mines |
| 6 | VI | Awoken Hrungnir | Aydeewa Subterrane map 2 (E-7) | Survival Guide to Aydeewa Subterrane |
| 7 | VII | Awoken Morbol Emperor | Arrapago Reef map 3 (H-6) | Survival Guide to Caedarva Mire, run east into Arrapago Reef |
| 8 | VIII | Awoken Stoorworm | Reisenjima, Ethereal Ingress #9 | Dimensional Ring to Reisenjima, take Ethereal Ingress #9 |
| 9 | IX | Awoken Dendainsonne | Western Altepa Desert (I-6) | Unity warp (CL125) to W. Altepa, footprints NW of zone-in |
| 10 | X | Awoken Freke | Batallia Downs (J-7) | HP Upper Jeuno #1, zone into Batallia, north of the road |
| 11 | XI | Awoken Tanngrisnir | Qufim Island (G-8) | HP to Qufim Island |
| 12 | XII | Awoken Nihhus | Kamihr Drifts (F-8) | HP Ra'Kaznar Inner Court, cast Escape (alt: waypoint Outer Ra'Kaznar, exit east) |
| 13 | XIII | Awoken Hakenmann | Rala Waterways (N-5) | HP #1 Eastern Adoulin, enter Rala Waterways at (F-7) |
| 14 | XIV | Awoken Andhrimnir | Newton Movalpolos (L-9) | HP #1 Newton Movalpolos, short walk |
| 15 | XV | Awoken Angantyr, Hjorvarth, Hrani | Xarcabard (D-8) | HP Castle Zvahl Keep, cast Escape (alt: SG to Zvahl Baileys, walk out) |

## Notes

- Peculiar Foes objectives are under Records of Eminence > Other > RoE Quests 4. They're unlocked by talking to Elijah in Upper Jeuno (G-6) as you progress The Voracious Resurgence.
- The objectives reset with each monthly version update. Use `//pf reset` to clear done marks for the new month.
- Done marks, auto and style all reset when the addon reloads.
- Footprints reappear 3 minutes after the foe dies.

## Settings

Set at the top of `PFtracker.lua`:

- `line_delay`: seconds between party lines (default 1.5)
- `auto_delay`: seconds after RoE completes before posting the next foe (default 3)
- `fancy`: fancy or plain party text on load (default true)
- `auto`: auto-next on load (default false)
- Colors used for local chat output

## Troubleshooting

**Auto next isn't posting.** Run `//pf list`. The last line shows whether auto is on. When a foe completes, your log should say "<foe> done".

**Nothing shows when the RoE completes.** Turn on `//pf debug`. You should see "RoE complete seen" when the objective completes. If you don't, the message isn't reaching the addon.

**Symbols look garbled.** Run `//pf style` to switch to plain text.

## Sources

Locations and routes are from [BG-Wiki: Peculiar Foes](https://www.bg-wiki.com/ffxi/Peculiar_Foes) and [FFXIclopedia: Records of Eminence > Other](https://ffxiclopedia.fandom.com/wiki/Other).
