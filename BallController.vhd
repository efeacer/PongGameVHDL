---------------------------------------------------------------------------------- 
-- Engineer: EFE ACER
-- Project Name: Pong Game
-- Brief: This is a module to compute and return the position of the ball according
--        to the inputs given to it (positions of the paddles). The module interacts
--        with the Sync module to inform it about the balls position. It also handles
--        some the game logic and informs Sync about what to draw to the screen.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Constants.all;

entity BallController is
  Port (start, move: in std_logic;
        paddleWidth: in integer;
        paddlePos, paddleAIPos: in integer range TOT_H - VIS_H + 1 to TOT_H - PADDLE_WIDTH;
        xPos: out integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE;
        yPos: out integer range TOT_V - VIS_V + 1 to TOT_V;
        newGame, play, AIWon, PlayerWon: out std_logic);
end BallController;

architecture Behavioral of BallController is
--Intermediate signals
signal currentX: integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE:= BALL_INITIAL_X;
signal currentY: integer range TOT_V - VIS_V + 1 to TOT_V:= BALL_INITIAL_Y;
signal playingCurrent: std_logic:= '0';
signal resetCurrent: std_logic:= '1';
signal playerWins, AIWins: std_logic:= '0';	
begin
 process(move)
 variable wallHorizontalBounce, paddleSideBounce, paddleSurfaceBounce, paddleAISideBounce, paddleAISurfaceBounce: boolean := false; --Collision indicating variables
 variable horizontalVelocity: integer:= -1; -- -1: left & up 1: right & down 
 variable verticalVelocity: integer:= -1; -- -1: left & up 1: right & down 
    begin
        if move'event and move = '1' then --The signals inside the process are only updated in the rising edges of the move signal.
            --Win/End conditions
            if currentY <= FP_V + SP_V + BP_V + 1 then
                playerWins <= '1';
            elsif start = '1' then
                playerWins <= '0';
            end if;
            if currentY >= TOT_V then
                AIWins <= '1';
            elsif start = '1' then
                AIWins <= '0';
            end if;
            --Reset Logic
            if AIWins = '1' or playerWins = '1' then
                currentX <= BALL_INITIAL_X;
                currentY <= BALL_INITIAL_Y;
                playingCurrent <= '0';
                resetCurrent <= '1';
            elsif start = '1' then
                playingCurrent <= '1';
                resetCurrent <= '0';
            end if;
            --Collision Detection Statements (searches for the intersections between the ball and the specified objects)
            wallHorizontalBounce := currentX <= FP_H + SP_H + BP_H + 1 or currentX >= TOT_H - BALL_SIDE;
            paddleSurfaceBounce := currentY >= TOT_V - PADDLE_HEIGHT - BALL_SIDE and 
                                   currentX >= paddlePos and 
                                   currentX <= paddlePos + paddleWidth - BALL_SIDE;
            paddleSideBounce := ((currentX = paddlePos - 9 or currentX = paddlePos - 8 or currentX = paddlePos + paddleWidth or currentX = paddlePos + paddleWidth - 1)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 10)) or
                                ((currentX = paddlePos - 8 or currentX = paddlePos - 7 or currentX = paddlePos + paddleWidth - 1 or currentX = paddlePos + paddleWidth - 2)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 9)) or
                                ((currentX = paddlePos - 7 or currentX = paddlePos - 6 or currentX = paddlePos + paddleWidth - 2 or currentX = paddlePos + paddleWidth - 3)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 8)) or
                                ((currentX = paddlePos - 6 or currentX = paddlePos - 5 or currentX = paddlePos + paddleWidth - 3 or currentX = paddlePos + paddleWidth - 4)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 7)) or
                                ((currentX = paddlePos - 5 or currentX = paddlePos - 4 or currentX = paddlePos + paddleWidth - 4 or currentX = paddlePos + paddleWidth - 5)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 6)) or
                                ((currentX = paddlePos - 4 or currentX = paddlePos - 3 or currentX = paddlePos + paddleWidth - 5 or currentX = paddlePos + paddleWidth - 6)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 5)) or
                                ((currentX = paddlePos - 3 or currentX = paddlePos - 2 or currentX = paddlePos + paddleWidth - 6 or currentX = paddlePos + paddleWidth - 7)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 4)) or
                                ((currentX = paddlePos - 2 or currentX = paddlePos - 1 or currentX = paddlePos + paddleWidth - 7 or currentX = paddlePos + paddleWidth - 8)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 3)) or
                                ((currentX = paddlePos - 1 or currentX = paddlePos or currentX = paddlePos + paddleWidth - 8 or currentX = paddlePos + paddleWidth - 9)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 2)) or
                                ((currentX = paddlePos or currentX = paddlePos + 1 or currentX = paddlePos + paddleWidth - 9 or currentX = paddlePos + paddleWidth - 10)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 1)) or
                                ((currentX = paddlePos + 1 or currentX = paddlePos + 2 or currentX = paddlePos + paddleWidth - 10 or currentX = paddlePos + paddleWidth - 11)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE));
            paddleAISurfaceBounce := currentY <= FP_V + SP_V + BP_V + PADDLE_HEIGHT and 
                                     currentX >= paddleAIPos and 
                                     currentX <= paddleAIPos + PADDLE_WIDTH - BALL_SIDE;
            paddleAISideBounce := ((currentX = paddleAIPos - 9 or currentX = paddleAIPos - 8 or currentX = paddleAIPos + PADDLE_WIDTH or currentX = paddleAIPos + PADDLE_WIDTH - 1)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 10)) or
                                  ((currentX = paddleAIPos - 8 or currentX = paddleAIPos - 7 or currentX = paddleAIPos + PADDLE_WIDTH - 1 or currentX = paddleAIPos + PADDLE_WIDTH - 2)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 9)) or
                                  ((currentX = paddleAIPos - 7 or currentX = paddleAIPos - 6 or currentX = paddleAIPos + PADDLE_WIDTH - 2 or currentX = paddleAIPos + PADDLE_WIDTH - 3)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 8)) or
                                  ((currentX = paddleAIPos - 6 or currentX = paddleAIPos - 5 or currentX = paddleAIPos + PADDLE_WIDTH - 3 or currentX = paddleAIPos + PADDLE_WIDTH - 4)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 7)) or
                                  ((currentX = paddleAIPos - 5 or currentX = paddleAIPos - 4 or currentX = paddleAIPos + PADDLE_WIDTH - 4 or currentX = paddleAIPos + PADDLE_WIDTH - 5)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 6)) or
                                  ((currentX = paddleAIPos - 4 or currentX = paddleAIPos - 3 or currentX = paddleAIPos + PADDLE_WIDTH - 5 or currentX = paddleAIPos + PADDLE_WIDTH - 6)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 5)) or
                                  ((currentX = paddleAIPos - 3 or currentX = paddleAIPos - 2 or currentX = paddleAIPos + PADDLE_WIDTH - 6 or currentX = paddleAIPos + PADDLE_WIDTH - 7)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 4)) or
                                  ((currentX = paddleAIPos - 2 or currentX = paddleAIPos - 1 or currentX = paddleAIPos + PADDLE_WIDTH - 7 or currentX = paddleAIPos + PADDLE_WIDTH - 8)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 3)) or
                                  ((currentX = paddleAIPos - 1 or currentX = paddleAIPos or currentX = paddleAIPos + PADDLE_WIDTH - 8 or currentX = paddleAIPos + PADDLE_WIDTH - 9)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 2)) or
                                  ((currentX = paddleAIPos or currentX = paddleAIPos + 1 or currentX = paddleAIPos + PADDLE_WIDTH - 9 or currentX = paddleAIPos + PADDLE_WIDTH - 10)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 1)) or
                                  ((currentX = paddleAIPos + 1 or currentX = paddleAIPos + 2 or currentX = paddleAIPos + PADDLE_WIDTH - 10 or currentX = paddleAIPos + PADDLE_WIDTH - 11)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT));
            --Next state logics for the position and velocity of the ball                      
            if wallHorizontalBounce or paddleSideBounce then
               horizontalVelocity := - horizontalvelocity;
            elsif playingCurrent = '0' then
               horizontalVelocity := -1; 
            end if;
            if paddleSurfaceBounce or paddleSideBounce or paddleAISurfaceBounce or paddleAISideBounce then
                verticalVelocity :=  - verticalVelocity;
            elsif playingCurrent = '0' then
                verticalVelocity := -1;
            end if;
            if playingCurrent = '1' then
                currentX <= currentX + horizontalVelocity;
                currentY <= currentY + verticalVelocity;
            end if;
        end if;
    end process;
    --Register to update the main signals
    xPos <= currentX;
    yPos <= currentY;
    play <= playingCurrent;
    newGame <= resetCurrent;
    AIWon <= AIWins;
    playerWon <= playerWins;
end Behavioral;
