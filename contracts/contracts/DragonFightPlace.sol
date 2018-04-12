pragma solidity ^0.4.21;

import "./DragonFightGC.sol";

contract DragonsFightPlace is DragonFightGC {
    
    uint256 public totalDragonsToFight;
    uint256 public priceToFight = 0.01 ether; // price for test
    uint256 public priceToAdd = 0;  // price for test
    mapping(uint256 => address) dragonsOwner;
    mapping(uint256 => uint256) public dragonsEndBlock;
    uint256[] public dragonsList; 
    mapping(uint256 => uint256) dragonsListIndex;


    function DragonsFightPlace(address _wallet) public {
        wallet = _wallet;
    }

    function _delItem(uint256 _dragonID) private {
        delete(dragonsOwner[_dragonID]);
        delete(dragonsEndBlock[_dragonID]);
        if (totalDragonsToFight > 1) {
            dragonsList[dragonsListIndex[_dragonID]] = dragonsList[dragonsList.length - 1];
        }
        dragonsList.length--;
        delete(dragonsListIndex[_dragonID]);
        totalDragonsToFight--;
    }
    function addToFightPlace(uint256 _dragonID, uint256 _endBlockNumber) external payable whenNotPaused {
        require(_endBlockNumber  > minFightWaitBloc);
        require(_endBlockNumber < maxFightWaitBloc); //??????
        address dragonOwner = mainContract.ownerOf(_dragonID);
        require(dragonOwner == msg.sender);
        require(msg.value >= priceToAdd);
        uint256 valueToReturn = msg.value - priceToAdd;
        if (priceToFight != 0) {
        wallet.transfer(priceToAdd);
        }
        
        if (valueToReturn != 0) {
            msg.sender.transfer(valueToReturn);
        }
        dragonsOwner[_dragonID] = dragonOwner;
        dragonsEndBlock[_dragonID] = block.number + _endBlockNumber;
        dragonsListIndex[_dragonID] = dragonsList.length;
        dragonsList.push(_dragonID);
        totalDragonsToFight++;
        // TODO add dragon blocking
    }
    
    function delFromFightPlace(uint256 _dragonID) external {
        require(msg.sender == dragonsOwner[_dragonID] || dragonsEndBlock[_dragonID] < block.number);
         // TODO add dragon unblocking   
        _delItem(_dragonID);
    }

    function fightWithDragon(uint256 _yourDragonID,uint256 _thisDragonID) external payable whenNotPaused {
        require(block.number <= dragonsEndBlock[_thisDragonID]);
        require(msg.value >= priceToFight);
        require(mainContract.ownerOf(_yourDragonID) == msg.sender);
        
        uint256 valueToReturn = msg.value - priceToFight;
        if (priceToFight != 0) {
        wallet.transfer(priceToFight);
        }
        
        if (valueToReturn != 0) {
            msg.sender.transfer(valueToReturn);
        }
        // TODO fight
        // TODO change stat + rest time
        // TODO add mutagen
        if (dragonFightContract.getWinner(_yourDragonID, _thisDragonID) == _yourDragonID ) {
            
            dragonStatsContract.incFightWin(_yourDragonID);
            dragonStatsContract.incFightLose(_thisDragonID);
            
        } else {
            
            dragonStatsContract.incFightWin(_thisDragonID);
            dragonStatsContract.incFightLose(_yourDragonID);
            
        }
        // TODO add dragon unblocking
        
        _delItem(_thisDragonID);        
    }
    function getAllDragonsFight() external view returns(uint256[]) {
        return dragonsList;
    }
    function getDragonsTofight() external view returns(uint256[]) {
        

        if (totalDragonsToFight == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            // !!!!!! need to test on time go to future
            uint256[] memory result = new uint256[](totalDragonsToFight);
            uint256 _dragonIndex;
            uint256 _resultIndex = 0;

            for (_dragonIndex = 0; _dragonIndex < totalDragonsToFight; _dragonIndex++) {
                uint256 _dragonID = dragonsList[_dragonIndex];
                if (dragonsEndBlock[_dragonID] > block.number) {
                    result[_resultIndex] = _dragonID;
                    _resultIndex++;
                }
            }

            return result;
        }
    }
    function clearStuxDragon(uint256 _start, uint256 _count) external whenNotPaused returns (uint256 _deleted) {
        uint256 _dragonIndex;
        
        for(_dragonIndex=_start; _dragonIndex < _start + _count && _dragonIndex < dragonsList.length; _dragonIndex++) {
            uint256 _dragonID = dragonsList[_dragonIndex];
            if (dragonsEndBlock[_dragonID] < block.number) {
                // TODO add dragon unblocking
                _delItem(_dragonID);
                _deleted++;
            }
        }
    }
   
    


    function changePrices(uint256 _priceToFight,uint256 _priceToAdd) external onlyOwner {
        priceToFight = _priceToFight;
        priceToAdd = _priceToAdd;
    }

    function withdrawAllEther() external onlyOwner {
        require(wallet != 0);
        wallet.transfer(address(this).balance);
    }
}

