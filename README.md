Starting this script displays a text representation of a guitar fretboard.
An `X` marks a random location on the fretboard, and you have a few seconds
(set with `--period` option) to find the corresponding note before the answer
shows, together with the next random `X`.


Usage
-----

    > lib/fretboarder.rb [options]


Options
-------

    -p, --period [TIME]              Period in seconds between each question (default: 3)
    -s, --start [FRET]               Starting fret for questions (default: 0)
    -e, --end [FRET]                 Ending fret for questions (default: 12)
    -b, --use-flats                  Use flats (default: use sharps)
    -h, --help                       Show this message


Screenshot
----------

Well, it's an ASCII screenshot...

    Question 2:
    
    -----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
    -----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
    -----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
    -----||-----|-----|-----|-----|-----|-----|-----|-----|--B--|-----|-----|-----|
    -----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|--X--|
    -----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
                         .           .           .           .                 :

Here the `B` is the answer to the previous question, `X` is the current question, and
by default you have three seconds before the answer shows, together with the next question.


Note
----

See [abc notation](http://abcnotation.com) about note notations.
