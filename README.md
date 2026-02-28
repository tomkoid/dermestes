# Dermestes

Dermestes is a top-down action arcade game built in Godot 4.6. You play as a
beetle surviving in a graveyard. Coffins are your only food source. Eat them to
stay alive, fend off rival insects that compete for the same meals, and collect
cards from each coffin you consume.

The name of this game comes from Dermestes, a genus of hide beetles known for stripping
carcasses clean.


## Gameplay

You start on a tiled grid scattered with coffins. Your health drains
continuously from starvation. Move close to a coffin and hold the eat button to
feed. Eating restores health and slowly depletes the coffin. Once a coffin is
fully consumed it disappears and a new one spawns at a random location on the
map.

Each time you fully eat a coffin you draw a random card. You can hold a maximum
of two cards at once. Click a card in your hand to activate and discard it.


## Cards

Cards come in three types.

Attack cards eliminate enemies in a nearby area. The current attack cards are
Hornet, Kratos, and Legolas.

Intellect cards restore 30 HP instantly. The current intellect cards are
Dr. House, Nathan Drake, and Dash.

Defense cards provide a shield. The current defense cards are Jindrich ze
Skalice, Captain America, and Gandalf.

If your hand is full at two cards, new coffin kills do not grant additional
cards until you use one.


## Controls

Movement: WASD or arrow keys, left analogue stick on gamepad.

Eat: Space, Enter, or the corresponding gamepad face button. Hold while standing
next to a coffin to feed.

Use card: left-click the card panel displayed on the right side of the screen.


## Running the project

Open the project in Godot 4.6 or later. The main scene is scenes/main.tscn.
Hit run from the editor or export using the provided export presets.

