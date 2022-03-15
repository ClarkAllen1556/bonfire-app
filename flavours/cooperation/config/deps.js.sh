#!/bin/sh

# Add any extensions/deps with a package.json in their /assets directory here
# NOTE: any LV Hooks should also be added to ./deps_hooks.js
// TODO: make this more configurable? ie. autogenerate from active extensions with JS assets

DEPS='bonfire_common bonfire_ui_social bonfire_editor_ck bonfire_geolocate bonfire_ui_kanban'

chmod +x ./priv/deps.js.sh
./priv/deps.js.sh "$DEPS"