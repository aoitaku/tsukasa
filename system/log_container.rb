#! ruby -E utf-8

require 'dxruby'
require_relative './module_movable.rb'
require_relative './module_drawable.rb'
require_relative './control_container.rb'

###############################################################################
#TSUKASA for DXRuby  α１
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

#ログコンテナ
class LogContainer < Control

  #移動関連モジュール読み込み
  include Movable
  include Drawable

  def initialize(options)
    @total_width = options[:width] || raise
    @total_height =options[:height] || raise

    #サーフェス生成
    @control = RenderTarget.new(options[:width], options[:height], [0, 0, 0, 0])
    super(options)
  end

  #コマンドをスタックに格納する
  #※TODO:createコマンドをオーバーロードするというのは避けられないのか？
  def command_create(options)
    case options[:add]
    when :top
      raise #現在の設計ではマイナス方向には追加できない

    when :bottom
      options[:x_pos] = 0
      options[:y_pos] = @control.height

      new_image = Module.const_get(options[:control]).new(options)
      @last_add_height = new_image.control.height

    when :left
      raise #現在の設計ではマイナス方向には追加できない

    when :right
      options[:x_pos] = @control.width
      options[:y_pos] = 0

      new_image = Module.const_get(options[:control]).new(options)
      @last_add_width  = new_image.control.width

    else
      raise #ひとまずそれ以外はサクる
    end

    #コントロールをリストに連結する
    @control_list.push(new_image)
  end

  def command_move_scroll(options)
    #必須属性値チェック
    return if check_exist(options, :frame, :scroll)

    options[:offset] = true

    case options[:scroll]
    when :top
      raise #TODO:未実装

    when :bottom
      options[:offset_x] = 0
      options[:offset_y] = -@last_add_height

    when :left
      raise #TODO:未実装

    when :right
      options[:offset_x] = -@last_add_width
      options[:offset_y] = 0

    else
      raise #ひとまずそれ以外はサクる
    end

    #所持している全コントロールにmove_lineコマンドを発行
    raise #下記メソッドは未検証
    send_script_to_all(:move, options)
  end

end
