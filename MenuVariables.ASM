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
    Difficulty_squares_gap = 20
    Squares_x = 600
    Squares_y = Difficulty_y+Difficulty_height+Difficulty_squares_gap
    TextDifficulty_width = 200
    Squares_height = 60
    Squares_width = 40
    Squares_Play_gap = 20

