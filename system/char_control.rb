#! ruby -E utf-8

require 'dxruby'

require_relative './Image_font_maker'

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

###############################################################################
#汎用テキストマネージャクラス
###############################################################################

class CharControl < ImageControl
  include Drawable

  ############################################################################
  #書体情報
  ############################################################################

  # 文字サイズ
  attr_reader :size    
  def size=(arg)
    @size = arg
    @option_update = true
  end

  #書体
  attr_reader :font_name
  def font_name=(arg)
    @font_name = arg
    @option_update = true
  end

  # 太字（bool|integer）にするかどうか。数字なら太さ
  attr_reader :weight    
  def weight=(arg)
    @weight = arg
    @option_update = true
  end

  # イタリック（bool）にするかどうか
  attr_reader :italic  
  def italic=(arg)
    @italic = arg
    @option_update = true
  end

  # 文字
  attr_reader :charactor    
  def charactor=(arg)
    @charactor = arg
    @option_update = true
  end

  ############################################################################
  #パラメーター
  ############################################################################

  #アンチエイリアスのオンオフ
  def aa=(arg)
    @font_draw_option[:aa] = arg
    @option_update = true
  end
  def aa
    @font_draw_option[:aa]
  end

  # 文字色
  def color=(arg)
    @font_draw_option[:color] = arg
    @option_update = true
  end
  def color
    @font_draw_option[:color]
  end

  ############################################################################
  #袋文字関連
  ############################################################################

  #袋文字を描画するかどうかをtrue/falseで指定します。
  def edge=(arg)
    @font_draw_option[:edge] = arg
    @option_update = true
  end
  def edge
    @font_draw_option[:edge]
  end

  #袋文字の枠色を指定します。配列で[R, G, B]それぞれ0～255
  def edge_color=(arg)
    @font_draw_option[:edge_color] = arg
    @option_update = true
  end
  def edge_color
    @font_draw_option[:edge_color]
  end

  #袋文字の枠の幅を0～の数値で指定します。1で1ピクセル
  def edge_width=(arg)
    @font_draw_option[:edge_width] = arg
    @option_update = true
  end
  def edge_width
    @font_draw_option[:edge_width]
  end

  #袋文字の枠の濃さを0～の数値で指定します。大きいほど濃くなりますが、幅が大きいほど薄くなります。値の制限はありませんが、目安としては一桁ぐらいが実用範囲でしょう。
  def edge_level=(arg)
    @font_draw_option[:edge_level] = arg
    @option_update = true
  end
  def edge_level
    @font_draw_option[:edge_level]
  end

  ############################################################################
  #影文字関連
  ############################################################################

  #影を描画するかどうかをtrue/falseで指定します
  def shadow=(arg)
    @font_draw_option[:shadow] = arg
    @option_update = true
  end
  def shadow
    @font_draw_option[:shadow]
  end

  #edgeがtrueの場合に、枠の部分に対して影を付けるかどうかをtrue/falseで指定します。trueで枠の影が描かれます
  def shadow_edge=(arg)
    @font_draw_option[:shadow_edge] = arg
    @option_update = true
  end
  def shadow_edge
    @font_draw_option[:shadow_edge]
  end

  #影の色を指定します。配列で[R, G, B]、それぞれ0～255
  def shadow_color=(arg)
    @font_draw_option[:shadow_color] = arg
    @option_update = true
  end
  def shadow_color
    @font_draw_option[:shadow_color]
  end

  #影の位置を相対座標で指定します。+1は1ピクセル右になります
  def shadow_x=(arg)
    @font_draw_option[:shadow_x] = arg
    @option_update = true
  end
  def shadow_x
    @font_draw_option[:shadow_x]
  end

  #影の位置を相対座標で指定します。+1は1ピクセル下になります
  def shadow_y=(arg)
    @font_draw_option[:shadow_y] = arg
    @option_update = true
  end
  def shadow_y
    @font_draw_option[:shadow_y]
  end

  #############################################################################
  #公開インターフェイス
  #############################################################################

  def initialize(options, inner_options, root_control)
    @font_draw_option = {}
    @font_obj = {}

    self.size = options[:size] || 24 #フォントサイズ
    self.font_name = options[:font_name] || "ＭＳ 明朝" #フォント名

    self.charactor = options[:charactor] || raise #描画文字

    self.weight = options[:bold] || false #太字
    self.italic = options[:italic] || false  #イタリック

    self.color = options[:color] || [255,255,255] #色
    self.aa = options[:aa] || true #アンチエイリアスのオンオフ

    self.edge = options[:edge] || true #縁文字
    self.shadow = options[:shadow] || true #影

    self.edge_color = options[:edge_color] || [0, 0, 0] #縁文字：縁の色
    self.edge_width = options[:edge_width] || 2 #縁文字：縁の幅
    self.edge_level = options[:edge_level] || 16 #縁文字：縁の濃さ

    self.shadow_color = options[:shadow_color] || [0, 0, 0] #影：影の色
    self.shadow_x = options[:shadow_x] || 0 #影:オフセットＸ座標
    self.shadow_y = options[:shadow_y] || 0 #影:オフセットＹ座標

    super
  end

  def render(offset_x, offset_y, target, parent_size)
    if @option_update

      @font_obj = Font.new( @size, 
                            @font_name, 
                            { :weight=>@weight, 
                              :italic=>@italic})

      #現状での縦幅、横幅を取得
      @real_width = @width  = @font_obj.get_width(@charactor)
      @real_height = @height = @font_obj.size

      #イタリックの場合、文字サイズの半分を横幅に追加する。
      if @italic
        @real_width = @width + @font_draw_option[:size]/2
      end

      #影文字の場合、オフセット分を縦幅、横幅に追加する
      if @font_draw_option[:shadow]
        @real_width   = @width  + @font_draw_option[:shadow_x]
        @real_height  = @height + @font_draw_option[:shadow_y]
      end

      #袋文字の場合、縁サイズの２倍を縦幅、横幅に追加し、縁サイズ分をオフセットに加える。
      if @font_draw_option[:edge]
        @real_width   = @width  + @font_draw_option[:edge_width] * 2
        @real_height  = @height + @font_draw_option[:edge_width] * 2
        @offset_x = -1 * @font_draw_option[:edge_width]
        @offset_y = -1 * @font_draw_option[:edge_width]
      else
        @offset_x = 0
        @offset_y = 0
      end

      #文字用のimageを作成
      @entity = Image.new(@real_width, @real_height, [0, 0, 0, 0]) 

      #フォントを描画
      @entity.draw_font_ex( -1 * @offset_x, 
                            -1 * @offset_y, 
                            @charactor, 
                            @font_obj, 
                            @font_draw_option)

      @option_update = false
    end

    dx, dy = super

    return dx, dy

  end

  #############################################################################
  #非公開インターフェイス
  #############################################################################

  private

  #############################################################################
  #文字列関連コマンド
  #############################################################################

end
