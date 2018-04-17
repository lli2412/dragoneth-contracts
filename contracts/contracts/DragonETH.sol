pragma solidity ^0.4.21;

import "./ERC721/ERC721Token.sol";
import "./DragonETH_GC.sol";
import "./security/ReentrancyGuard.sol";

// FOR TEST remove in war deploy
// contract DragonETH is ERC721Token("DragonETH game", "DragonETH"), DragonETH_GC, ReentrancyGuard {
contract DragonETH is ERC721Token("Test game", "Test"), DragonETH_GC, ReentrancyGuard {
    uint256 public totalDragons;
    uint256 public liveDragons;
    struct Dragon {
        uint256 gen1;
        uint8 stage; // 0 - Dead, 1 - Egg, 2 - Young Dragon 
        uint8 currentAction; // 0 - free, 1 - fight place, 0xFF - Necropolis,  2 - random fight, 3 - breed market, 4 - breed auction, 5 - random breed ...
        uint240 gen2;
        uint256 nextBlock2Action;
    }
    Dragon[] public dragons;
    
   
    function DragonETH(address _wallet, address _necropolisContract, address _dragonStatsContract) public {
        
        _mint(msg.sender, 0);
        Dragon memory _dragon = Dragon({
            gen1: 0,
            stage: 0,
            currentAction: 0,
            gen2: 0,
            nextBlock2Action: UINT256_MAX
        });
        dragons.push(_dragon);
        dragonStatsContract = DragonStats(_dragonStatsContract);
        necropolisContract = Necropolis(_necropolisContract);
        wallet = _wallet;
    }
   
    function add2MarketPlace(uint256 _dragonID, uint256 _dragonPrice, uint256 _endBlockNumber) external onlyOwnerOf(_dragonID)  {
        require(dragons[_dragonID].stage != 0); // dragon not dead
        if (dragons[_dragonID].stage >= 2) {
            checkDragonStatus(_dragonID, 2);
        }
        if (fmpContractAddress.add2MarketPlace(msg.sender, _dragonID, _dragonPrice, _endBlockNumber)) {
        transferFrom(msg.sender, fmpContractAddress, _dragonID);
        }
    }

    function add2Auction(uint256 _dragonID,  uint256 _startPrice, uint256 _step, uint256 _endPrice, uint256 _endBlockNumber) external onlyOwnerOf(_dragonID)  {
        require(dragons[_dragonID].stage != 0); // dragon not dead
        if (dragons[_dragonID].stage >= 2) {
            checkDragonStatus(_dragonID, 2);
        }
        if (auctionContract.add2Auction(msg.sender, _dragonID, _startPrice, _step, _endPrice, _endBlockNumber)) {
        transferFrom(msg.sender, auctionContract, _dragonID);
        }
    }
    
    function addRandomFight2Death(uint256 _dragonID) external payable nonReentrant onlyOwnerOf(_dragonID)   {
        checkDragonStatus(_dragonID, adultDragonStage);
        if (priceRandomFight2Death > 0) {
            require(msg.value >= priceRandomFight2Death);
            wallet.transfer(priceRandomFight2Death);
            if (msg.value - priceRandomFight2Death > 0) msg.sender.transfer(msg.value - priceRandomFight2Death);
        }
        transferFrom(msg.sender,randomFight2DeathContract, _dragonID);
        randomFight2DeathContract.addRandomFight2Death(msg.sender, _dragonID);
    }
    
    function addSelctFight2Death(uint256 _yourDragonID, uint256 _oppDragonID, uint256 _endBlockNumber) external payable nonReentrant onlyOwnerOf(_yourDragonID)   {
        checkDragonStatus(_yourDragonID, adultDragonStage);
        if (priceSelectFight2Death > 0) {
            require(msg.value >= priceSelectFight2Death);
            address(selectFight2DeathContract).transfer(priceSelectFight2Death);
            if (msg.value - priceSelectFight2Death > 0) msg.sender.transfer(msg.value - priceSelectFight2Death);
        }
        transferFrom(msg.sender,selectFight2DeathContract, _yourDragonID);
        selectFight2DeathContract.addSelctFight2Death(msg.sender, _yourDragonID, _oppDragonID, _endBlockNumber, priceSelectFight2Death);
        
    }
    
    function mutagen2Face(uint256 _dragonID, uint256 _mutagenCount) external onlyOwnerOf(_dragonID)   {
        checkDragonStatus(_dragonID, 2);
        transferFrom(msg.sender,mutagen2FaceContract, _dragonID);
        mutagen2FaceContract.addDragon(msg.sender, _dragonID, _mutagenCount);
    }
    
    
    function createDragon(address _to, uint256 _timeToBorn, uint256 _parentOne, uint256 _parentTwo, uint256 _gen1, uint240 _gen2) external onlyRole("CreateContract") {
        totalDragons++;
        liveDragons++;
        // TODO add chek to safeTransfer
        _mint(_to, totalDragons);
        uint256[2] memory twoGen;
        if (_parentOne == 0 && _parentTwo == 0 && _gen1 == 0 && _gen2 == 0) {
            twoGen = genRNGContractAddress.getNewGens(_to, totalDragons);
        } else {
            twoGen[0] = _gen1;
            twoGen[1] = uint256(_gen2);
        }
        Dragon memory _dragon = Dragon({
            gen1: twoGen[0],
            stage: 1,
            currentAction: 0,
            gen2: uint240(twoGen[1]),
            nextBlock2Action: _timeToBorn 
        });
        dragons.push(_dragon);
        if (_parentOne !=0) {
            dragonStatsContract.setParents(totalDragons,_parentOne,_parentTwo);
            dragonStatsContract.incChildren(_parentOne);
            dragonStatsContract.incChildren(_parentTwo);
        }
        dragonStatsContract.setBirthBlock(totalDragons);
    }
    function changeDragonGen(uint256 _dragonID, uint256 _gen, uint8 _which) external onlyRole("ChangeContract") {
        if (_which == 0) {
            dragons[_dragonID].gen1 = _gen;
        } else {
            dragons[_dragonID].gen2 = uint240(_gen);
        }
    }
    function birthDragon(uint256 _dragonID) external onlyOwnerOf(_dragonID) {
        require(dragons[_dragonID].stage != 0); // dragon not dead
        require(dragons[_dragonID].nextBlock2Action <= block.number);
        dragons[_dragonID].stage = 2;
    }
    function matureDragon(uint256 _dragonID) external onlyOwnerOf(_dragonID) {
        checkDragonStatus(_dragonID, 2);
        require(dragonStatsContract.getDragonFight(_dragonID) >= 100);
        dragons[_dragonID].stage = 3;
        
    }
    function superDragon(uint256 _dragonID) external onlyOwnerOf(_dragonID) {
        checkDragonStatus(_dragonID, 3);
        require(superContract.checkDragon(_dragonID));
        dragons[_dragonID].stage = 4;
    }
    function killDragon(uint256 _dragonID) external onlyOwnerOf(_dragonID) {
        checkDragonStatus(_dragonID, 2);
        dragons[_dragonID].stage = 0;
        dragons[_dragonID].currentAction = 0xFF;
        dragons[_dragonID].nextBlock2Action = UINT256_MAX;
        necropolisContract.addDragon(ownerOf(_dragonID), _dragonID, 1);
        transferFrom(msg.sender, necropolisContract, _dragonID);
        dragonStatsContract.setDeathBlock(_dragonID);
        liveDragons--;
    }
    function killDragonDeathContract(address _lastOwner, uint256 _dragonID, uint256 _deathReason) external onlyOwnerOf(_dragonID) onlyRole("DeathContract") {
        checkDragonStatus(_dragonID, 2);
        dragons[_dragonID].stage = 0;
        dragons[_dragonID].currentAction = 0xFF;
        dragons[_dragonID].nextBlock2Action = UINT256_MAX;
        necropolisContract.addDragon(_lastOwner, _dragonID, _deathReason);
        transferFrom(msg.sender, necropolisContract, _dragonID);
        dragonStatsContract.setDeathBlock(_dragonID);
        liveDragons--;
        
    }
    function decraseTimeToAction(uint256 _dragonID) external payable nonReentrant onlyOwnerOf(_dragonID) {
        require(dragons[_dragonID].stage != 0); // dragon not dead
        require(msg.value >= priceDecraseTime2Action);
        require(dragons[_dragonID].nextBlock2Action > block.number);
        uint256 maxBlockCount = dragons[_dragonID].nextBlock2Action - block.number;
        if (msg.value > maxBlockCount * priceDecraseTime2Action) {
            msg.sender.transfer(msg.value - maxBlockCount * priceDecraseTime2Action);
            wallet.transfer(maxBlockCount * priceDecraseTime2Action);
            dragons[_dragonID].nextBlock2Action = 0;
        } else {
            if (priceDecraseTime2Action == 0) {
                dragons[_dragonID].nextBlock2Action = 0;
            } else {
                wallet.transfer(msg.value);
                dragons[_dragonID].nextBlock2Action =  dragons[_dragonID].nextBlock2Action - msg.value / priceDecraseTime2Action - 1;
            }
            
            
            
        }
        
    }
    function checkDragonStatus(uint256 _dragonID, uint8 _stage) public view {
        require(dragons[_dragonID].stage != 0); // dragon not dead
         // dragon not in action and not in rest  and not egg
        require(dragons[_dragonID].nextBlock2Action <= block.number && dragons[_dragonID].currentAction == 0 && dragons[_dragonID].stage >=_stage);
    }
    function setCurrentAction(uint256 _dragonID, uint8 _currentAction) external onlyRole("ActionContract") {
        dragons[_dragonID].currentAction = _currentAction;
    }
    function setTime2Rest(uint256 _dragonID, uint256 _addNextBlock2Action) external onlyRole("ActionContract") {
        dragons[_dragonID].nextBlock2Action = block.number + _addNextBlock2Action;
    }
    
    
    
    function getDragonGens(uint256 _dragonID) external view returns(bytes32 _res1, bytes32 _res2 ) {
        
    _res1 = bytes32(dragons[_dragonID].gen1);
    _res2 = bytes32(dragons[_dragonID].gen2);
    }
    
}
