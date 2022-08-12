Novice Summer Jam https://itch.io/jam/nsjs-2022-jam-9

due <t:1660384800:R>

Theme: One button input


Morse code game
Concept: You are a prisoner in solitary cell, using a tap code on the wall of the cell to communicate with the prisoner in the next cell.

Requirements:

- Prisoner's tap code
- Knock sound effect
- Something to talk about


TODO:

 - [] main menu
 - [] scene swapper
 - [] change between knock mode and dialog mode
 - [] background image(s)
 - [] polish knock UI
 - [] polish dialog UI
 - [] multiple choice knocks for interrogation


# Defining Conversations

Conversations are defined via JSON in `scenes/conversations.json`. This consists of a root-level dictionary mapping conversation IDs to definitions. Example:

```
{
	"test_dialog": {
		"type": "Dialog",
		"strings": [
			"TEST_0",
			"TEST_1",
			"TEST_2"
		],
		"image": "InterrogationBackground.png"
		"next_conversation": "test_knock"
	},
	"test_knock": {
		"type": "KnockCode",
		"strings": [
			"TEST_KNOCK_RECEIVED_0",
			TEST_KNOCK_REQUIRES
		],
		"image": "CellBackground.png"
	}
}
```