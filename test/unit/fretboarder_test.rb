# -*- coding: utf-8 -*-
#
# test.rb
#

require 'test/unit'
require 'fretboarder'

# old_question = new_question
# new_question = FretQuestion.new 1, 12

# answer = KeyboardAnswer.new key

# fretboard.answer! answer, old_question
# fretboard.ask! new_question
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
        assert fretboard.isCorrect?(goodAnswer, question)
        assert !fretboard.isCorrect?(wrongAnswer, question)

        otherQuestion = FretQuestion.new 6, 0
        assert_equal "E,", fretboard.answerTo(otherQuestion)
        assert fretboard.isCorrect?(goodAnswer, otherQuestion)

        assert !fretboard.isCorrect?(KeyboardAnswer.new(?f), FretQuestion.new(1, 2))
    end

    def test_fretboard_display_data_with_question
        fretboard = Fretboard.new
        assert_equal({}, fretboard.displayData)

        new_question = FretQuestion.new 6, 0
        fretboard.ask! new_question
        assert_equal({[6, 0] => ["X", :blue]}, fretboard.displayData)
    end

    def test_fretboard_display_data_with_answer
        fretboard = Fretboard.new

        old_question = FretQuestion.new 6, 0
        right = KeyboardAnswer.new ?d
        slow = SlowKeyboardAnswer.new ?d
        wrong = KeyboardAnswer.new ?f

        fretboard.answer! right, old_question
        assert_equal({[6, 0] => ["E,", :green]}, fretboard.displayData)
        fretboard.answer! slow, old_question
        assert_equal({[6, 0] => ["E,", :yellow]}, fretboard.displayData)
        fretboard.answer! wrong, old_question
        assert_equal({[6, 0] => ["E,", :red]}, fretboard.displayData)
    end

    def test_fret_coords
        start = 1
        fretboard = Fretboard.new
        # -----||-----|-----|-----|
        assert_equal start, (fretboard.fretStart 0)
        assert_equal start+7, (fretboard.fretStart 1)
        assert_equal start+13, (fretboard.fretStart 2)
    end

    def test_fret_text_coords
        start = 1
        fretboard = Fretboard.new
        # --X--||-----|-----|
        assert_equal 3, (fretboard.textStart 'X', 0)
        # -----||--X--|-----|
        assert_equal 10, (fretboard.textStart 'X', 1)
        # -----||-----|--X--|
        assert_equal 16, (fretboard.textStart 'X', 2)
        # -----||-----|-^f--|
        assert_equal 15, (fretboard.textStart '^f', 2)
        # -----||-----|--f,-|
        assert_equal 16, (fretboard.textStart 'f,', 2)
    end
end
