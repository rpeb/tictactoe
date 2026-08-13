function love.load()
	clickedCellNumber = nil
	gameState = {
		BEGINNING = "beginning",
		IN_PROGRESS = "inProgress",
		END = "end",
	}
	currentGameState = gameState.BEGINNING
	gameWinner = nil
	cells = {
		{
			x = 0, -- centre coordinates
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
		{
			x = 0,
			y = 0,
			symbol = "",
		},
	}
	currPlayer = nil
	love.window.setTitle("Tic Tac Toe")
	screenWidth = 800
	screenHeight = 600
	love.window.setMode(screenWidth, screenHeight)
	wu = screenWidth / 5
	hu = screenHeight / 5
	line1Horizontal = {
		x1 = wu,
		y1 = 2 * hu,
		x2 = 4 * wu,
		y2 = 2 * hu,
	}
	line2Horizontal = {
		x1 = wu,
		y1 = 3 * hu,
		x2 = 4 * wu,
		y2 = 3 * hu,
	}
	line1Vertical = {
		x1 = 2 * wu,
		y1 = hu,
		x2 = 2 * wu,
		y2 = 4 * hu,
	}
	line2Vertical = {
		x1 = 3 * wu,
		y1 = hu,
		x2 = 3 * wu,
		y2 = 4 * hu,
	}
	player1ChosenKeyCoords = { wu / 2, screenHeight - hu / 2 }
	player2ChosenKeyCoords = { screenWidth - wu / 2, screenHeight - hu / 2 }
	chooseASymbolMessage = "Press x or o to Start"
	player1sTurn = "Player 1's turn"
	player2sTurn = "Player 2's turn"
	chosenSymbol = ""
	firstPlayersSymbol = ""
	secondPlayersSymbol = ""
end

function love.draw()
	if currentGameState == gameState.BEGINNING then
		love.graphics.print(chooseASymbolMessage, wu, hu / 2)
	end
	love.graphics.setColor(1, 1, 1)
	-- 2 lines horizontal
	love.graphics.line(line1Horizontal.x1, line1Horizontal.y1, line1Horizontal.x2, line1Horizontal.y2)
	love.graphics.line(line2Horizontal.x1, line2Horizontal.y1, line2Horizontal.x2, line2Horizontal.y2)
	love.graphics.line(line1Vertical.x1, line1Vertical.y1, line1Vertical.x2, line1Vertical.y2)
	love.graphics.line(line2Vertical.x1, line2Vertical.y1, line2Vertical.x2, line2Vertical.y2)
	if chosenSymbol == "x" then
		love.graphics.print("player 1 -> x", player1ChosenKeyCoords[1], player1ChosenKeyCoords[2])
		love.graphics.print("player 2 -> o", player2ChosenKeyCoords[1] - wu, player2ChosenKeyCoords[2])
	elseif chosenSymbol == "o" then
		love.graphics.print("player 1 -> o", player1ChosenKeyCoords[1], player1ChosenKeyCoords[2])
		love.graphics.print("player 2 -> x", player2ChosenKeyCoords[1] - wu, player2ChosenKeyCoords[2])
	end

	if currentGameState ~= gameState.BEGINNING then
		for i = 1, #cells do
			local cell = cells[i]
			love.graphics.print(cell.symbol, cell.x, cell.y)
		end
	end

	if currentGameState == gameState.IN_PROGRESS then
		if currPlayer == 1 then
			love.graphics.print(player1sTurn, wu, hu / 2)
		else
			love.graphics.print(player2sTurn, wu, hu / 2)
		end
	end

	if gameWinner then
		love.graphics.setColor(0, 1, 0)
		love.graphics.print("Player " .. gameWinner .. " won!!", wu, hu / 2)
		love.graphics.setColor(1, 1, 1)
	elseif gameWinner == nil and currentGameState == gameState.END then
		love.graphics.setColor(1, 0, 0)
		love.graphics.print("match tie", wu, hu / 2)
		love.graphics.setColor(1, 1, 1)
	end
end

function love.keypressed(key)
	if key == "x" then
		chosenSymbol = "x"
		firstPlayersSymbol = "x"
		secondPlayersSymbol = "o"
	elseif key == "o" then
		chosenSymbol = "o"
		firstPlayersSymbol = "o"
		secondPlayersSymbol = "x"
	end
	if currentGameState == gameState.BEGINNING and (chosenSymbol == "x" or chosenSymbol == "o") then
		currPlayer = 1
		currentGameState = gameState.IN_PROGRESS
	end
end

function love.mousereleased(x, y)
	-- get the coordinates of centre of clickedCellNumber (centre of clickedCellNumber is point of intersection of its diagonals)
	if currentGameState ~= gameState.IN_PROGRESS then
		return
	end
	clickedCellNumber = getClickedCellNumber(x, y)
	if not clickedCellNumber then
		return
	end
	populateClickedCell(clickedCellNumber)
	checkAndAnnounceWinner(clickedCellNumber)
	endGameIfAllCellsFull()
	togglePlayersTurn()
end

function endGameIfAllCellsFull()
	local filledCell = 0
	for i = 1, #cells do
		if cells[i].symbol ~= "" then
			filledCell = filledCell + 1
		end
	end

	if filledCell == #cells then
		currentGameState = gameState.END
	end
end

function checkAndAnnounceWinner(cellNo)
	local diagCell = false
	if cellNo % 2 == 1 then
		diagCell = true
	end
	local matched = false
	local rowsM = checkRows(clickedCellNumber)
	local colsM = checkCols(clickedCellNumber)
	if diagCell then
		local diagM = checkDiag(clickedCellNumber)
		matched = rowsM or colsM or diagM
	else
		matched = rowsM or colsM
	end
	if matched then
		gameWinner = getPlayerBySign(cells[clickedCellNumber].symbol)
		currentGameState = gameState.END
	end
end

function checkRows(clickedCellNumber)
	if cells[clickedCellNumber].symbol == "" then
		return false
	end
	if clickedCellNumber <= 3 then
		return cells[1].symbol == cells[2].symbol and cells[2].symbol == cells[3].symbol
	elseif clickedCellNumber <= 6 then
		return cells[4].symbol == cells[5].symbol and cells[5].symbol == cells[6].symbol
	else
		return cells[7].symbol == cells[8].symbol and cells[8].symbol == cells[9].symbol
	end
end

function checkCols(clickedCellNumber)
	if cells[clickedCellNumber].symbol == "" then
		return false
	end
	if clickedCellNumber == 1 or clickedCellNumber == 4 or clickedCellNumber == 7 then
		return cells[1].symbol == cells[4].symbol and cells[4].symbol == cells[7].symbol
	elseif clickedCellNumber == 2 or clickedCellNumber == 5 or clickedCellNumber == 8 then
		return cells[2].symbol == cells[5].symbol and cells[5].symbol == cells[8].symbol
	else
		return cells[3].symbol == cells[6].symbol and cells[6].symbol == cells[9].symbol
	end
end

function checkDiag(clickedCellNumber)
	if cells[clickedCellNumber].symbol == "" then
		return false
	end
	if clickedCellNumber == 5 then
		return (cells[1].symbol == cells[5].symbol and cells[5].symbol == cells[9].symbol)
			or (cells[3].symbol == cells[5].symbol and cells[5].symbol == cells[7].symbol)
	end
	if clickedCellNumber == 1 or clickedCellNumber == 9 then
		return cells[1].symbol == cells[5].symbol and cells[5].symbol == cells[9].symbol
	else
		return cells[3].symbol == cells[5].symbol and cells[5].symbol == cells[7].symbol
	end
end

function getPlayerBySign(sign)
	if sign == firstPlayersSymbol then
		return 1
	else
		return 2
	end
end

function togglePlayersTurn()
	if currPlayer == 1 then
		currPlayer = 2
	else
		currPlayer = 1
	end
end

function populateClickedCell(clickedCellNumber)
	-- clickedCellNumber = 1, 2, 3.. 9
	local row = math.floor((clickedCellNumber - 1) / 3)
	local col = clickedCellNumber % 3
	if col == 0 then
		col = 3
	end
	local x1 = (col - 1) * wu
	local x2 = x1 + wu
	local y1 = row * hu
	local y2 = y1 + hu
	local xc = (x1 + x2) / 2
	local yc = (y1 + y2) / 2
	cells[clickedCellNumber].x = xc + wu
	cells[clickedCellNumber].y = yc + hu
	if currPlayer == 1 then
		cells[clickedCellNumber].symbol = firstPlayersSymbol
	else
		cells[clickedCellNumber].symbol = secondPlayersSymbol
	end
end

function getClickedCellNumber(x, y)
	if x >= wu and x < 2 * wu then
		if y >= hu and y < 2 * hu then
			return 1
		elseif y >= 2 * hu and y < 3 * hu then
			return 4
		elseif y >= 3 * hu and y <= 4 * hu then
			return 7
		end
	elseif x >= 2 * wu and x < 3 * wu then
		if y >= hu and y < 2 * hu then
			return 2
		elseif y >= 2 * hu and y < 3 * hu then
			return 5
		elseif y >= 3 * hu and y <= 4 * hu then
			return 8
		end
	else
		if x >= 3 * wu and x <= 4 * wu then
			if y >= hu and y < 2 * hu then
				return 3
			elseif y >= 2 * hu and y < 3 * hu then
				return 6
			elseif y >= 3 * hu and y <= 4 * hu then
				return 9
			end
		end
	end
end
