#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# fretboarder.rb
#

require 'optparse'
require 'ncurses'

$NOTES = [["e", "f", "^f", "g", "^g", "a", "^a", "b", "c'", "^c'", "d'", "^d'", "e'"],
          ["B", "c", "^c", "d", "^d", "e", "f", "^f", "g", "^g", "a", "^a", "b"],
          ["G", "^G", "A", "^A", "B", "c", "^c", "d", "^d", "e", "f", "^f", "g"],
          ["D", "^D", "E", "F", "^F", "G", "^G", "A", "^A", "B", "c", "^c", "d"],
          ["A,", "^A,", "B", "C", "^C", "D", "^D", "E", "F", "^F", "G", "^G", "A"],
          ["E,", "F,", "^F,", "G,", "^G,", "A,", "^A,", "B,", "C", "^C", "D", "^D", "E"]]

$FLAT_NOTES = [["e", "f", "_g", "g", "_a", "a", "_b", "b", "c'", "_d'", "d'", "_e'", "e'"],
               ["B", "c", "_d", "d", "_e", "e", "f", "_g", "g", "_a", "a", "_b", "b"],
               ["G", "_A", "A", "_B", "B", "c", "_d", "d", "_e", "e", "f", "_g", "g"],
               ["D", "_E", "E", "F", "_G", "G", "_A", "A", "_B", "B", "c", "_d", "d"],
               ["A,", "_B,", "B", "C", "_D", "D", "_E", "E", "F", "_G", "G", "_A", "A"],
               ["E,", "F,", "_G,", "G,", "_B,", "A,", "_B,", "B,", "C", "_D", "D", "_E", "E"]]

$NB_STRINGS = $NOTES.size
$NB_FRETS = $NOTES[0].size - 1

$settings = {
    :period => 3,
    :start => 0,
    :end => $NB_FRETS,
    :use_flats => false,
    :display_map => false
}

class FretQuestion
    attr_reader :stringNumber, :fretNumber
    def initialize stringNumber, fretNumber
        @stringNumber = stringNumber
        @fretNumber = fretNumber
    end
end

class KeyboardAnswer
    def initialize char = nil
        @noteName = note_for_character char
    end

    def noteName
        @noteName
    end

    def isSlow?
        false
    end

    def isValid?
        return nil != @noteName && !mustQuit?
    end

    def note_for_character character
        use_sharps = !$settings[:use_flats]
        b2 = use_sharps ? '^c' : '_d'
        table = {
            ?a => 'c',
            ?w => b2,
            ?s => 'd',
            ?e => use_sharps ? '^d' : '_e',
            ?d => 'e',
            ?f => 'f',
            ?t => use_sharps ? '^f' : '_g',
            ?g => 'g',
            ?y => use_sharps ? '^g' : '_a',
            ?h => 'a',
            ?u => use_sharps ? '^a' : '_b',
            ?j => 'b',
            # and for AZERTY users:
            ?q => 'c',
            ?z => b2,
            ?\e => :quit,
            ?\C-c => :quit
        }
        table[character]
    end

    def mustQuit?
        return :quit == @noteName
    end
end

class SlowKeyboardAnswer < KeyboardAnswer
    def isSlow?
        true
    end
end

class Fretboard
    attr_reader :displayData

    def initialize
        @displayData = {}
        @fretWidth = 5
    end

    def answerTo question
        notes = $settings[:use_flats] ? $FLAT_NOTES : $NOTES
        notes[question.stringNumber-1][question.fretNumber]
    end

    def isCorrect? anAnswer, aQuestion
        if !anAnswer.isValid?
            return false
        end
        regexp = Regexp.new('^' + Regexp.quote(anAnswer.noteName), Regexp::IGNORECASE)
        regexp.match(answerTo aQuestion)
    end

    def answer! anAnswer, aQuestion
        result = true
        hasAnswer = nil != anAnswer
        stringNumber = aQuestion.stringNumber
        fretNumber = aQuestion.fretNumber
        colorName = (hasAnswer && anAnswer.isSlow?) ? :yellow : :green
        if hasAnswer && !isCorrect?(anAnswer, aQuestion)
            colorName = :red
            result = false
        end
        @displayData[[stringNumber, fretNumber]] = [answerTo(aQuestion), colorName]
        result
    end

    def ask! aQuestion
        stringNumber = aQuestion.stringNumber
        fretNumber = aQuestion.fretNumber
        @displayData[[stringNumber, fretNumber]] = ['X', :blue]
    end

    def fretStart fretNumber
        start = 1
        if 0 != fretNumber
            nutWidth = 1
            start = start + nutWidth + fretNumber*(@fretWidth+1)
        end
        start
    end

    def textStart text, fretNumber
        start = fretStart fretNumber
        offset = 0
        firstLeterMatchData = text.match /[a-z]/i
        if firstLeterMatchData
            offset = -(firstLeterMatchData.begin 0)
        end
        start + @fretWidth / 2 + offset
    end

    def draw y, window
        offset = y
        $NOTES.each_index do |i|
            stringNumber = i + 1
            y = stringNumber + offset
            $NOTES[i].each_index do |fretNumber|
                x = (fretStart fretNumber)
                emptyFret = fretNumber == 0 ? '-----||' : '-----|'
                window.mvaddstr y, x, emptyFret
                textData = @displayData[[stringNumber, fretNumber]]
                if textData
                    text = textData[0]
                    x = textStart text, fretNumber
                    color = $COLOR[textData[1]]
                    window.color_set(color, nil)
                    window.mvaddstr y, x, text
                    window.color_set($COLOR[:origin], nil)
                end
            end
        end
        window.mvaddstr($NB_STRINGS + offset+1, 0,
                        "                      .           .           .           .                 :")
    end
end

def random_string
    rand($NB_STRINGS) + 1
end

def random_fret
    rand($settings[:end] - $settings[:start] + 1) + $settings[:start]
end

$COLOR = {
    :origin => 0,
    :blue => 1,
    :green => 2,
    :yellow => 3,
    :red => 4,
}

def quizz
    stats = {
        :start => Time.new,
        :success => 0,
        :slow => 0,
        :failure => 0,
        :nbQuestions => 1
    }

    question = nil
    questionStart = Time.new

    answer = KeyboardAnswer.new
    window = Ncurses.stdscr
    while :quit != answer.noteName do
        window.clear
        window.mvaddstr 1, 0, "Question #{stats[:nbQuestions]}:"
        fretboard = Fretboard.new
        old_question = question
        question = FretQuestion.new random_string, random_fret
        fretboard.ask! question
        if old_question
            result = fretboard.answer! answer, old_question
            if result
                stats[:success] += 1
            else
                stats[:failure] +=1
            end
        end
        fretboard.draw 2, window
        stats[:nbQuestions] = stats[:nbQuestions] + 1
        start = Time.new
        window.mvaddstr 11, 0, "#{stats[:success]} success, #{stats[:slow]} slow, #{stats[:failure]} errors."
        window.mvaddstr 13, 0, "A, S, D, F,... to answer (corresponds to C, D, E, F,...), and ESC to quit."
        window.refresh

        answerChar = Ncurses.getch
        isAnswerSlow = Time.new - start > $settings[:period]
        if isAnswerSlow
            answer = SlowKeyboardAnswer.new answerChar
            stats[:slow] += 1
        else
            answer = KeyboardAnswer.new answerChar
        end
    end
    stats
end

def auto_quizz
    nbQuestions = 1
    question = nil

    window = Ncurses.stdscr
    Ncurses.stdscr.nodelay true
    Ncurses.timeout 0
    key = nil
    start = Time.new - $settings[:period]

    while ?\e != key && ?\C-c != key do
        key = Ncurses.getch
        if Time.new - start >= $settings[:period]
            fretboard = Fretboard.new
            previous_question = question
            if previous_question then
                fretboard.answer! nil, previous_question
            end

            question = FretQuestion.new random_string, random_fret
            fretboard.ask! question

            window.clear
            window.mvaddstr 1, 0, "Question #{nbQuestions}:"
            fretboard.draw 2, window
            window.refresh
            start = Time.new
            nbQuestions = nbQuestions + 1
        end
        sleep(0.01)
    end
end

def display_map
    window = Ncurses.stdscr
    fretboard = Fretboard.new
    $NOTES.each_index do |i|
        stringNumber = i + 1
        $NOTES[i].each_index do |fretNumber|
            fretboard.answer! nil, FretQuestion.new(stringNumber, fretNumber)
        end
    end
    window.clear
    window.mvaddstr 1, 0, "Fretboard map:"
    fretboard.draw 2, window
    window.mvaddstr 11, 0, "Press any key to quit."
    window.refresh
    Ncurses.getch
end

if __FILE__ == $0

    option_parser = OptionParser.new do |opts|
        opts.banner = """Usage: #{__FILE__} [options]
Note: see http://abcnotation.com about note notations.

"""
        opts.on("-p", "--period [TIME]", "Period in seconds between each question (default: #{$settings[:period]})") do |p|
            $settings[:period] = Float(p)
        end
        opts.on("-s", "--start [FRET]", "Starting fret for questions (default: #{$settings[:start]})") do |s|
            $settings[:start] = Integer(s)
        end
        opts.on("-e", "--end [FRET]", "Ending fret for questions (default: #{$settings[:end]})") do |e|
            $settings[:end] = Integer(e)
        end
        opts.on("-b", "--use-flats", "Use flats (default: use sharps)") do |b|
            $settings[:use_flats] = b
        end
        opts.on("-m", "--display-map", "Shows a fretboard map and exits") do |m|
            $settings[:display_map] = m
        end
        opts.on("-a", "--auto", "In this mode inputs are ignored: the answer periodically shows up with another question.") do |a|
            $settings[:auto] = a
        end

        opts.on_tail("-h", "--help", "Show this message and exits") do
            puts opts
            exit
        end
    end
    option_parser.parse!(ARGV)

    begin
        Ncurses.initscr
        Ncurses.start_color
        bg = Ncurses::COLOR_BLACK
        Ncurses.init_pair($COLOR[:blue], Ncurses::COLOR_CYAN, bg)
        Ncurses.init_pair($COLOR[:green], Ncurses::COLOR_GREEN, bg)
        Ncurses.init_pair($COLOR[:yellow], Ncurses::COLOR_YELLOW, bg)
        Ncurses.init_pair($COLOR[:red], Ncurses::COLOR_RED, bg)

        # if (Ncurses.has_colors?)
        #     bg = Ncurses::COLOR_BLACK
        #     Ncurses.start_color
        #     if (Ncurses.respond_to?("use_default_colors"))
        #         if (Ncurses.use_default_colors == Ncurses::OK)
        #             bg = -1
        #         end
        #     end
        #     Ncurses.init_pair(1, Ncurses::COLOR_GREEN, bg);
        #     Ncurses.init_pair(2, Ncurses::COLOR_YELLOW, bg);
        #     Ncurses.init_pair(3, Ncurses::COLOR_RED, bg);
        # end
        Ncurses.nl
        Ncurses.noecho
        Ncurses.curs_set 0
        #        Ncurses.stdscr.nodelay true
        #        Ncurses.timeout 0
        Ncurses.raw
        #        Ncurses.stdscr.keypad true
        if $settings[:display_map]
            display_map
        elsif $settings[:auto]
            auto_quizz
        else
            quizz
        end
    ensure
        Ncurses.curs_set 1
        Ncurses.endwin
    end
end
