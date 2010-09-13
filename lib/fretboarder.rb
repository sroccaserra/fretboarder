#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# fretboarder.rb
#

require 'optparse'
require 'rubygems'
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
    def initialize char
        @noteName = note_for_character char
    end

    def noteName
        @noteName
    end

    def isSlow?
        false
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
            ?z => b2
        }
        table[character]
    end
end

class SlowKeyboardAnswer < KeyboardAnswer
    def isSlow?
        true
    end
end

class Fretboard
    def initialize
    end

    def answerTo question
        notes = $settings[:use_flats] ? $FLAT_NOTES : $NOTES
        notes[question.stringNumber-1][question.fretNumber]
    end

    def isCorrect anAnswer, aQuestion
        (answerTo aQuestion).match anAnswer.noteName
    end

    def correct anAnswer, aQuestion
        @oldQuestion = aQuestion
    end

    def ask aQuestion
        @question = aQuestion
    end

    def displayData
        data = {}
        stringNumber = @oldQuestion.stringNumber
        fretNumber = @oldQuestion.fretNumber
        data[[stringNumber, fretNumber]] = answerTo(@oldQuestion)
    end
end

def random_string
    rand($NB_STRINGS) + 1
end

def random_fret options
    rand(options[:end] - options[:start] + 1) + options[:start]
end



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

    red = 3
    green = 1
    yellow = 2
    answer = nil
    while ?q != answer && 27 != answer do
        fretboardData = {}
        previous_question = question
        answer = Ncurses.getch
        Ncurses.addstr "a: #{answer}\n"
    end
end

def auto_quizz
    nbQuestions = 1
    question = nil

    while true do
        fretboardData = {}
        previous_question = question
        if previous_question then
            stringNumber = previous_question[:string]
            fretNumber = previous_question[:fret]
            fretboardData[[stringNumber, fretNumber]] = Fret.new(Fretboard.note(stringNumber, fretNumber))
        end

        stringNumber = random_string
        fretNumber = random_fret $settings
        question = {
            :string => stringNumber,
            :fret => fretNumber
        }

        fretboardData[[stringNumber, fretNumber]] = Fret.new('X', '5;1;32;44')
        fretboard = Fretboard.new fretboardData
        fretboard_string = fretboard.toString
        Ncurses.clear
        Ncurses.addstr "\nQuestion #{nbQuestions}:\n\n#{fretboard_string}\n#{Fretboard.marks}"
        Ncurses.refresh
        sleep($settings[:period])
        nbQuestions = nbQuestions + 1
    end
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
        opts.on("-a", "--auto", "In this mode, as soon as the time is up, the answer shows up with another question.") do |a|
            $settings[:auto] = a
        end

        opts.on_tail("-h", "--help", "Show this message and exits") do
            puts opts
            exit
        end
    end
    option_parser.parse!(ARGV)

    if $settings[:display_map]
        help_fretboard_data = {}
        1.upto $NB_STRINGS do |stringNumber|
            0.upto $NB_FRETS do |fretNumber|
                help_fretboard_data[[stringNumber, fretNumber]] = Fret.new(Fretboard.note(stringNumber, fretNumber))
            end
        end
        puts "\nFretboard map:\n\n#{Fretboard.new(help_fretboard_data).toString}\n#{Fretboard.marks}"
        exit 0
    end

    begin
        Ncurses.initscr
        if (Ncurses.has_colors?)
            bg = Ncurses::COLOR_BLACK
            Ncurses.start_color
            if (Ncurses.respond_to?("use_default_colors"))
                if (Ncurses.use_default_colors == Ncurses::OK)
                    bg = -1
                end
            end
            Ncurses.init_pair(1, Ncurses::COLOR_GREEN, bg);
            Ncurses.init_pair(2, Ncurses::COLOR_YELLOW, bg);
            Ncurses.init_pair(3, Ncurses::COLOR_RED, bg);
        end
        Ncurses.nl
        Ncurses.noecho
        Ncurses.curs_set 0
        #        Ncurses.stdscr.nodelay true
        #        Ncurses.timeout 0
        Ncurses.cbreak
        #        Ncurses.stdscr.keypad true
        if $settings[:auto]
            auto_quizz
        else
            quizz
        end
    ensure
        Ncurses.curs_set 1
        Ncurses.endwin
    end
end
