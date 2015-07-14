#! ruby -E utf-8

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
  end
end

about :button1 do
  _CASE_ -> {true} do
    _WHEN_ -> {3 ** 3 == 30} do
      move_line x: 300, y: 0,   count:0, frame: 60, start_x: 0,   start_y: 0
      wait_command :move_line
      move_line x: 300, y: 300, count:0, frame: 60, start_x: 300, start_y: 0
      wait_command :move_line
      move_line x: 0,   y: 300, count:0, frame: 60, start_x: 300, start_y: 300
      wait_command :move_line
      move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 0,   start_y: 300
      wait_command :move_line
    end
    _WHEN_ -> {2 ** 2 != 4} do
      move_line x: 300, y: 300,   count:0, frame: 60, start_x: 0,   start_y: 0
      wait_command :move_line
      move_line x: 300, y: 0, count:0, frame: 60, start_x: 300, start_y: 300
      wait_command :move_line
      move_line x: 0,   y: 300, count:0, frame: 60, start_x: 300, start_y: 0
      wait_command :move_line
      move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 0,   start_y: 300
      wait_command :move_line
    end
    _ELSE_ do
      move_line x: 0, y: 300,   count:0, frame: 60, start_x: 0,   start_y: 0
      wait_command :move_line
      move_line x: 300, y: 300, count:0, frame: 60, start_x: 0, start_y: 300
      wait_command :move_line
      move_line x: 300,   y: 0, count:0, frame: 60, start_x: 300, start_y: 300
      wait_command :move_line
      
      _IF_ -> {4 ** 4 < 300} do
        _THEN_ do
          move_line x: 0,   y: 0,   count:0, frame: 60, start_x: 300,   start_y: 0
          wait_command :move_line
        end
        _ELSE_ do
          move_line x: 0,   y: 300,   count:0, frame: 60, start_x: 300,   start_y: 0
          wait_command :move_line
        end
      end
    end
  end
end
