## [3.0.1] - 14/03/2021
Fix issue #7
Update readme

## [3.0.0] - 14/03/2021
Use the dart migrate tool to migrate to null safety; test pass but I didn't test in production yet

## [2.0.2] - 14/11/2020
After an implementation on my side, i've discover some new needs and bugs that I implement and fix. Feel free to submit needs that can be added
- Added a method to remove from the master (In case your user can remove a flashcard from a deck)
- Adapt method cardExistInMaster to receive a String instead of Int
- Correct the method cardReviewedAtDateLength to return the correct date
- Return null instead of Throw an error in Main when a card does not exist in Master.

## [2.0.1] - 28/09/2020
- Added two new field in DRCard LastReviewed and DueDate. It will be null if the card hasn't been show yet (mostly in learning state)  
- Added method getAllCardStates which return all the card and their combinaison (so if it's double faced you'll  get two time the  same item but with a different front and back but same ID). 
- Added method cardReviewedTodayLength & cardReviewedAtDateLength to know which the number of cards that has  been  reviewed today  or at  a specific date. 
- Added cardsLength  method which return the length of the state 
- Rewrite a bit some methods to be more clear or accurate. 

## [2.0.0] - 25/09/2020
BREAKING CHANGE 
- Change type  of  Master Id from  int to String to support guid and more complex ID.

NON BREAKING CHANGE
- Use the analysis_options.yaml from dart pub

## [1.0.9] - 24/09/2020
- Rewrite the code to be more "Dart" way; remove static for Utility class (Still in progress)
- Add depedencies on Equatable to check equality instead of manually overriding.
- Added Analysis_options.yaml for better code quality

## [1.0.8] - 24/09/2020
- Removed the last new
- Update doc

## [1.0.7] - 24/09/2020
- Merged PR which put the test dependencies to dev_dep
- Update Dart 2.9
- Remove new keyword from the whole project

## [1.0.6] - 13/05/2019
- Merged PR that make the code more readable and add optional parameters
- Update Dart 2.3.0 

## [1.0.5] - 02/04/2019

- Fix issue when selecting hard multiple time
- Remove a print in the code

## [1.0.4] - 26/03/2019

- Release on pub dart
- Change models name to not conflict with material flutter app

## [0.0.1] - 23/03/2019

- Simple translation of the JS module to Dart as much as I can.
- Buggy and probably not the best code so I'll refactor.
