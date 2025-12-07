# YADC - Yet Another Dough Calculator

YADC is a dough calculator for amateur bakers. With YADC, bakers can create a new dough in two ways:

- enter a hydration, number of dough balls and weight per ball, percentage of other ingredients (yeast, salt etc.) and get a list of ingredients with their weight
- enter ingredients by weight (for example from an existing recipe found in a book), number of servings and calculate the hydration.

This second mode is something that none of the other calculators in the app store have, and it's the main reason for creating a new one. Once a recipe is entered, it can be scaled up or down for different numbers of dough balls.

One can switch between modes at any time multiple times, for example start with ingredients and then tweak the hydration.

The calculator can handle pre-ferments like poolish, biga etc., and allows to create custom ones.

## MVP

In the MVP, the focus is on the calculator which is the main view of the app. There is a single recipe persisted via UserDefaults. Managing multiple recipes will come later.

There is a settings page that allows switching from metrics to imperial, and to set a dough reasidue paramter as a percentage, representing the dough typically lost in the process.