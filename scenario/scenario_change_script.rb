#! ruby -E utf-8

###############################################################################
#TSUKASA for DXRuby α１
#汎用ゲームエンジン「司（TSUKASA）」 for DXRuby
#
#Copyright (c) <2013-2015> <tsukasa TSUCHIYA>
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#   1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
#
#   2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
#
#   3. This notice may not be removed or altered from any source
#   distribution.
#
#[The zlib/libpng License http://opensource.org/licenses/Zlib]
###############################################################################

#ボタン押下による範囲指定シナリオ分岐ギミックのサンプル
raise #現仕様では恐らく動作しない。要修正

#TODO：これ、動いてはいるけど元のon_key_upが上書きされているわけではない。
button  id: :button1, 
        x: 150,
        y: 150 do
  on_key_up do
    normal  {_SET_ visible: false}
    over    {_SET_ visible: true}
    key_down{_SET_ visible: false}
    _SET_ :_LOCAL_, flag: true
  end
end

_DEFINE_ :special_pause do
  pause do
    _CHECK_ [:not_null], not_null: :flag do
      _SET_ :_LOCAL_, scenario: 1
      _SET_ :_MODE_STATUS_, wake: true
      delete :message0
    end
  end
end

_SCOPE_ do
  text "スクリプト１－Ａ■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed

  special_pause
  _CHECK_ [:not_null], not_null: :flag do
    _RETURN_
  end

  flush
  text "スクリプト１－Ｂ■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed
  text "■■■■■■■■■■■■■■■■■■■■■■"
  line_feed

  special_pause
  _CHECK_ [:not_null], not_null: :flag do
    _RETURN_
  end

  _SET_ :_LOCAL_, scenario: 2
   delete :message0
end

TextWindow id: :message0, text_page_id: :default_text_page_control0,
  x: 128,
  y: 256 + 192,
  width: 1024,
  height: 192

_CHECK_ [:equal], equal: {:scenario => 1} do
  _INCLUDE_ "./scenario/scenario_change_script_3.rb"
end

_CHECK_ [:equal], equal: {:scenario => 2} do
  _INCLUDE_ "./scenario/scenario_change_script_2.rb"
end

text "インクルードしたスクリプト終了後処理はここに移ります"

pause