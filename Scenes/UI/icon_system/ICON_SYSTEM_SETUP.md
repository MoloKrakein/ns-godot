# UI Icon System Setup

This folder holds the reusable UI icon component and the small helper layer that feeds it.

The system is split into three parts:

- `UIIconStyle`: the data object for one icon, including the optional background and tint values.
- `UIIconSlot`: the scene component that draws the background layer and the icon layer.
- `UIIconLibrary`: small helper functions that build styles for moves, elements, reactions, and statuses.

## Core rule

The UI should not decide what an icon means. It should only receive a style and render it.

That keeps the icon logic composable:

- background on or off
- custom icon texture or theme fallback
- icon tint and background tint kept separate
- each scene can reuse the same slot without duplicating node logic

## Files

- `Scripts/UI/icon_system/ui_icon_style.gd`
- `Scripts/UI/icon_system/ui_icon_library.gd`
- `Scripts/UI/icon_system/ui_icon_slot.gd`
- `Scenes/UI/icon_system/ui_icon_slot.tscn`

## How to use it

1. Instance `Scenes/UI/icon_system/ui_icon_slot.tscn` inside the scene that needs an icon.
2. Assign a `UIIconStyle` to the slot, either in the inspector or from script.
3. Set `show_background` on the slot when the scene needs a bare icon.
4. Keep the background texture and icon texture separate so the same slot can be reused across move buttons, reaction badges, and small status markers.

Example from script:

```gdscript
var icon_slot: UIIconSlot = $IconSlot
var style: UIIconStyle = UIIconLibrary.create_move_style(move)
icon_slot.set_style(style)
```

## Scene setup guide

### Move button scene

Use the slot for the little icon area inside the move button.

Recommended setup:

- keep the button text in the button scene
- instance `UIIconSlot` next to the label
- call `UIIconLibrary.create_move_style(move)` when the button is built
- set `show_background = true` for regular moves
- set `show_background = false` for icon-only variants if you want a cleaner look

This is the best place to use the new system first, because the move button already needs an icon and can benefit from the optional background layer.

### Action menu scene

Use the same slot for the category buttons in `Scenes/UI/action_menu.tscn`.

Recommended setup:

- instance one `UIIconSlot` inside each action button
- use a shared style for menu actions that always have a background
- keep the text button separate from the icon slot
- use the slot only for visual identity, not for button logic

### Party panel scene

Use the slot only for small badge-style icons in `Scenes/UI/party_panel.tscn`.

Recommended setup:

- do not replace the whole portrait frame with the icon system
- use the slot for small markers like element, status, or turn-state badges
- set `show_background = false` for tiny overlay markers if the portrait frame already provides the backdrop
- set `show_background = true` only when the badge needs its own frame

### Runtime combat UI

The combat gym script can still create move buttons dynamically.

Recommended setup:

- use `UIIconLibrary.create_move_style(move)` when building the button UI
- pass the resulting style into the button's icon slot
- keep the battle logic separate from the icon rendering logic

### Element and physical icon data

The UI icon library now already knows the asset paths under `Arts/UI/Icons/Icons/` and the shared background at `Arts/UI/Icons/starbg.svg`.

The current element palette is:

- Fire: fill `#D70C0F`, stroke `#ECB726`
- Earth: fill `#00FF11`, stroke `#007D08`
- Light: fill `#FFF700`, stroke `#737000`
- Dark: fill `#270136`, stroke `#600AD6`
- Physical: fill `#686868`, stroke `#262525`

Use `UIIconLibrary.create_element_style(element)` for elemental icons and `UIIconLibrary.create_physical_style()` for the physical icon.

The slot still controls whether the background is visible, so these styles can be reused in both framed and icon-only scenes.

## Background rule

The background is optional and scene-driven.

- Use it when the icon needs its own shape or frame.
- Hide it when the icon is already sitting inside another framed element.
- Keep the background texture and the icon texture independent so either layer can be reused later.

## What to fill in later

When you send the per-element colors, each style can be expanded with:

- background fill color
- background stroke color
- icon fill color
- icon stroke color

At that point the slot can stay the same; only the style data changes.