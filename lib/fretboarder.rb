#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# fretboarder.rb
#

require 'optparse'
require 'curses'


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

class Fret
    def initialize note = nil, color = nil
        @note = note || ''
        @color = color
    end
    def toString
        fret = "-----"
        match_data = @note.match(/[a-z]/i)
        firstLetterPosition = match_data ? match_data.begin(0) : 0
        startIndex = fret.size - 3 - firstLetterPosition
        endIndex = startIndex + @note.size - 1
        text = @note
        if @color then
            text = "\e[#{@color}m#{@note}\e[0m"
        end
        fret[startIndex..endIndex] = text
        fret
    end
end

class Fretboard
    def self.note(stringNumber, fretNumber)
        $settings[:use_flats] ? $FLAT_NOTES[stringNumber-1][fretNumber] : $NOTES[stringNumber-1][fretNumber]
    end
    def self.marks
        "                     .           .           .           .                 :"
    end

    def initialize data
        @data = data
    end

    def stringFrets stringNumber
        stringData = @data.select {|k, v|
            k[0] == stringNumber
        }
        stringData.inject({}){|h, data|h.merge({data[0][1] => data[1]})}
    end

    def string stringNumber
        fretData = stringFrets stringNumber
        frets = Array.new($NB_FRETS + 1) do |index|
            fretData[index] || Fret.new()
        end
        separators = ["||"] + Array.new($NB_FRETS, '|')
        fretStrings = frets.collect {|fret| fret.toString}
        (fretStrings.zip separators).flatten.join
    end

    def toString
        strings = Array.new($NB_STRINGS) {|i| string(i+1)}
        strings.join "\n"
    end
end

def random_string
    rand($NB_STRINGS) + 1
end

def random_fret options
    rand(options[:end] - options[:start] + 1) + options[:start]
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

    red = '1;31'
    green = '0;32'
    yellow = '0;33'
    begin
        Curses.init_screen
        Curses.cbreak
        Curses.stdscr.keypad true
        answer = nil
        while ?q != answer && 27 != answer do
            answer = Curses.getch
            Curses.addstr "a: #{answer}\n"
        end
    ensure
        Curses.close_screen
    end
end

def auto_quizz
    nbQuestions = 1
    question = nil

    clearScreenSequence = "\e[2J\e[f"
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
        puts "#{clearScreenSequence}\nQuestion #{nbQuestions}:\n\n#{fretboard_string}\n#{Fretboard.marks}"
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

    if $settings[:auto]
        auto_quizz
    else
        quizz
    end
end
