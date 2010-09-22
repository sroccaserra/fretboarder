Starting this script displays a text representation of a guitar fretboard (see screenshot bellow).
An `X` marks a random location on the fretboard, and you have a few seconds
(set with `--period` option) to find the corresponding note.

Input your answer with the keyboard. A, S, D, F,... keys correspond to C, D, E, F,... notes,
with the W key for C# / Db, E key for D# / Eb,...

If you give the correct answer before the allowed period of time, the note will show up in green.

If you give the correct answer after the allowed period of time, the note will show up in yellow.

If you give a wrong answer, the correct answer will show up in red.


Requirements
------------

Fretboarder requires ncurses Ruby bindings. You can install them with:

    > gem install ncurses

Usage
-----

If you have the `RUBYOPT` environment variable set with `-rubygems`, or if you allready installed ncurses Ruby bindings outside gem, just start the script:

    > lib/fretboarder.rb [options]

Else, you can start it as:

    > ruby -rubygems src/fretboarder.rb [options]

Options
-------


    -p, --period [TIME]              Period in seconds between each question (default: 3)
    -s, --start [FRET]               Starting fret for questions (default: 0)
    -e, --end [FRET]                 Ending fret for questions (default: 12)
    -b, --use-flats                  Use flats (default: use sharps)
    -m, --display-map                Shows a fretboard map and exits
    -a, --auto                       In this mode inputs are ignored: the answer periodically shows up with another question.
    -h, --help                       Show this message and exits


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
