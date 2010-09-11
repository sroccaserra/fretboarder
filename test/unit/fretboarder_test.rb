# -*- coding: utf-8 -*-
#
# test.rb
#

require 'test/unit'
require 'fretboarder'

class TestFretboarder < Test::Unit::TestCase
    def test_fret
        assert_equal "-----", Fret.new.toString
        assert_equal "--X--", Fret.new('X').toString
        assert_equal "--F,-", Fret.new('F,').toString
        assert_equal "-^F,-", Fret.new('^F,').toString
        assert_equal "--\e[3mf'\e[0m-", Fret.new("f'", '3').toString
        assert_equal "-\e[3m_f'\e[0m-", Fret.new("_f'", '3').toString
    end

    def test_fretboard
        aFret = Fret.new 'X'
        anotherFret = Fret.new 'O'
        fretboard = Fretboard.new({
                                      [6, 1] => aFret,
                                      [5, 0] => aFret,
                                      [5, 1] => anotherFret
                                  })
        assert_equal({1 => aFret}, fretboard.stringFrets(6))
        assert_equal({0 => aFret, 1 => anotherFret}, fretboard.stringFrets(5))
        assert_equal("-----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|",
                     fretboard.string(1))
        assert_equal("-----||--X--|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|",
                     fretboard.string(6))
        assert_equal("--X--||--O--|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|",
                     fretboard.string(5))
        assert_equal("""
-----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
-----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
-----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
-----||-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
--X--||--O--|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
-----||--X--|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|""",
                     "\n"+fretboard.toString)
    end

    def test_fretboard_note
        assert_equal 'f', Fretboard.note(1, 1)
        assert_equal '^f', Fretboard.note(1, 2)
    end

    def test_character_to_note_association
        assert_equal 'c', note_for_character(?q)
        assert_equal 'd', note_for_character(?s)
        assert_equal 'e', note_for_character(?d)
        assert_equal 'f', note_for_character(?f)
    end
end
