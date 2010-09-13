# -*- coding: utf-8 -*-
#
# test.rb
#

require 'test/unit'
require 'fretboarder'

# old_question = new_question
# new_question = FretQuestion.new 1, 12

# answer = KeyboardAnswer.new key

# fretboard.correct answer, old_question
# fretboard.ask new_question
# fretboard.draw # -> Ncurses

class TestFretboarder < Test::Unit::TestCase
    def test_fret_question
        question = FretQuestion.new 1, 12
        assert_equal 1, question.stringNumber
        assert_equal 12, question.fretNumber
    end

    def test_keyboard_answer
        c = KeyboardAnswer.new ?q
        assert_equal 'c', c.noteName
        d = KeyboardAnswer.new ?s
        assert_equal 'd', d.noteName
        assert !d.isSlow?
        slowAnswer = SlowKeyboardAnswer.new ?d
        assert slowAnswer.isSlow?
    end

    def test_fretboard_questions
        fretboard = Fretboard.new
        question = FretQuestion.new 1, 12
        goodAnswer = KeyboardAnswer.new ?d
        wrongAnswer = KeyboardAnswer.new ?g

        assert_equal "e'", fretboard.answerTo(question)
        assert fretboard.isCorrect(goodAnswer, question)
        assert !fretboard.isCorrect(wrongAnswer, question)
    end

    def test_fretboard_display_data
        fretboard = Fretboard.new
        assert_equal({}, fretboard.displayData)

        old_question = FretQuestion.new 1, 12
        new_question = FretQuestion.new 6, 0
        answer = KeyboardAnswer.new ?d

        fretboard.correct answer, old_question
        assert_not_nil old_question
        assert_equal({[1, 12] => ["e'", :green]}, fretboard.displayData)
        fretboard.ask new_question

    end
end
