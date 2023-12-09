section '.data' data readable writeable
    Game_name db 'OSense',0
    SelectDifficulty db 'Select Difficulty : ',0
    Play db 'PLAY',0
    

    Name_x = 650
    Name_y = 250
    Name_width = 200
    Name_height = 50
    Name_Difficulty_gap = 50
    Difficulty_x = 600
    Difficulty_y = Name_y+Name_height+Name_Difficulty_gap
    Difficulty_height = 50
    Difficulty_width = 300
    Difficulty_squares_gap = 30
    Squares_x = 600
    Squares_y = Difficulty_y+Difficulty_height+Difficulty_squares_gap
    TextDifficulty_width = 200
    Squares_height = 60
    Squares_width = 40
    Squares_Play_gap = 30
    Play_x = 680
    Play_y = Squares_y + Squares_Play_gap + Squares_height
    Play_width = 120
    Play_height = 80

    SETTINGS dw 4,6,8,10,12,12,16,20,24,28,2,4,6,8,9
    Settings_name   db 'EASY',0
                    db 'NORMAL',0
                    db 'HARD', 0
                    db 'HARDER', 0
                    db 'INSANE', 0

    Setting_name_index dw 0

