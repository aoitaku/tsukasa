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
create :ImageControl ,
       file_path: "./sozai/bg_sample.png", x_po: 0, y_pos: 0, 
       id: :BG do
  move_line_with_skip x: 300, y: 0,   count:0, frame: 60, start_x: 0,   start_y: 0
  transition_fade_with_skip frame: 200,
                  count: 0,
                  start: 0,
                  last: 255
  wait_command :move_line_with_skip
  move_line_with_skip x: 0, y: 0,   count:0, frame: 60, start_x: 300,   start_y: 0
  wait_command :move_line_with_skip
end

#ボタンコントロール
create :ButtonControl, 
        :x_pos => 150, 
        :y_pos => 150, 
        :width => 256,
        :height => 256,
        :id=>:button1 do
  image :file_path=>"./sozai/button_normal.png", 
        :id=>:normal
  image :file_path=>"./sozai/button_over.png", 
        :id=>:over, :visible => false
  image :file_path=>"./sozai/button_key_down.png", 
        :id=>:key_down, :visible => false
  on_mouse_over do
    set :normal, visible: false
    set :over,   visible: true
    set :key_down, visible: false
  end
  on_mouse_out do
    set :over,   visible: false
    set :normal, visible: true
    set :key_down, visible: false
  end
  on_key_down do
    set :over,   visible: false
    set :normal, visible: false
    set :key_down, visible: true
  end
  on_key_up do
    set :key_down, visible: false
    set :normal, visible: false
    set :over,   visible: true
    EVAL "pp 'pre_wait'"
    flag :key=>3, :data=>2
    flag :key=>4, :data=>true
  end
end

WHILE ->{true}, :button1 do
  move_line x: 300, y: 0,   count:0, frame: 60, start_x: 0,   start_y: 0
  wait_command :move_line
  move_line x: 300, y: 300, count:0, frame: 60, start_x: 300, start_y: 0
  wait_command :move_line
  move_line x: 0,   y: 300, count:0, frame: 60, start_x: 300, start_y: 300
  wait_command :move_line
  move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 0,   start_y: 300
  wait_command :move_line
end

create :LayoutContainer,
  x_pos: 128,
  y_pos: 528,
  width: 1024,
  height: 600,
  id: :main_text_layer do
    #メッセージウィンドウ
    create :CharContainer, 
      x_pos: 2,
      y_pos: 2,
      id: :default_text_layer,
      font_config: { :size => 32, 
                     :face => "ＭＳＰ ゴシック"},
      style_config: { :wait_frame => 2,} do
      char_renderer do
        transition_fade_with_skip frame: 15,
          count: 0,
          start: 0,
          last: 255
        wait_command :transition_fade_with_skip
        sleep_mode :sleep
        wait_wake
        end_frame
        skip_mode false
        transition_fade_with_skip frame: 60,
          count: 0,
          start: 255,
          last:128
        wait_command :transition_fade_with_skip
      end
    end
  end

pause


dispose :button1

text "ＡＤＶエンジン「司（Tsuksisssssssssss"
line_feed
pause
text"asa）」のα１バージョンを"
line_feed
text "ひとまず"
pause
text"asa）」のα１バージョンを"
text "ひとまず"
line_feed
pause
text"公開します。testA"
pause
line_feed
text "ひとまず公開します。testA"
pause
text"asa）」のα１バージョンを"
line_feed
text "ひとまず"

#next_scenario "./scenario/scenario04b.rb"

#pause
#flash

