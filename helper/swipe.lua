local M={}

M.minSwipeDistance=100
M.minSwipeTime= 0.4
M.hashtouch=hash("touch")

function M.checkSwipeDirection(self, endX, endY)
    local xDistance
    local yDistance
    local totalSwipeDistanceLeft
    local totalSwipeDistanceRight
    local totalSwipeDistanceUp
    local totalSwipeDistanceDown
    local isSwipe=false
        if self.bDoingTouch == true then
                xDistance =  math.abs(endX - self.swipeBeginX) -- math.abs will return the absolute, or non-negative value, of a given value.
                yDistance =  math.abs(endY - self.swipeBeginY)
                if xDistance > yDistance then
                    if self.swipeBeginX > endX then
                        totalSwipeDistanceLeft = self.swipeBeginX - endX
                        if self.cbLeft and totalSwipeDistanceLeft > M.minSwipeDistance then
                                print("Swiped Left")
                                isSwipe=true
                                self.cbLeft(self)
                        end
                    else
                        totalSwipeDistanceRight = endX - self.swipeBeginX
                        if self.cbRight and totalSwipeDistanceRight > M.minSwipeDistance then
                                print("Swiped Right")
                                isSwipe=true
                                self.cbRight(self)
                        end
                    end
                else
                    if self.swipeBeginY > endY then
                        totalSwipeDistanceUp = self.swipeBeginY - endY
                        if self.cbDown and totalSwipeDistanceUp > M.minSwipeDistance then
                                print("Swiped Down", self.swipeBeginY)
                                isSwipe=true
                                self.cbDown(self)
                        end
                     else
                        totalSwipeDistanceDown = endY - self.swipeBeginY
                        if self.cbUp and totalSwipeDistanceDown > M.minSwipeDistance then
                                print("Swiped Up", self.swipeBeginY)
                                isSwipe=true
                                self.cbUp(self)
                        end
                     end
                end
        end
        if not isSwipe and self.cbTap then
            self.cbTap(self)
        end
 end

function M.init(self, cbLeft, cbRight, cbUp, cbDown, cbTap)
    self.cbLeft=cbLeft
    self.cbRight=cbRight
    self.cbUp=cbUp
    self.cbDown=cbDown
    self.cbTap=cbTap
    self.swipeStartTime=socket.gettime()
end

function M.final(self)
    self.cbLeft=nil
    self.cbRight=nil
    self.cbUp=nil
    self.cbDown=nil
    self.cbTap=nil
end

function M.on_input(self, action_id, action)
  if action_id == M.hashtouch then

    if action.pressed then
        --pprint(action)
        self.bDoingTouch = true
        self.swipeBeginX = action.x
        self.swipeBeginY = action.y
        self.swipeStartTime = socket.gettime()
    end
    if action.released  then
        --pprint(action)
        if socket.gettime() - self.swipeStartTime < M.minSwipeTime then
            M.checkSwipeDirection(self, action.x, action.y);
        elseif self.cbTap then
            self.cbTap(self)
        end
        self.bDoingTouch = false
    end
  end
end


return M
