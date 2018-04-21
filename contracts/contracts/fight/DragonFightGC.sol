pragma solidity ^0.4.21;

import "../security/Pausable.sol";
//import "./math/SafeMath.sol";

contract DragonETH {
    function ownerOf(uint256 _tokenId) public view returns (address);
}

contract DragonFight {
    function getWinner(uint256 _dragonOneID, uint256 _dragonTwoID) external returns (uint256 _winerID);
}

contract DragonStats {
    function incFightWin(uint256 _dragonID) external;
    function incFightLose(uint256 _dragonID) external;
    function incFightToDeathWin(uint256 _dragonID) external;
    function setLastAction(uint256 _dragonID, uint256 _lastActionDragonID, uint8 _lastActionID) external;
}

contract Mutagen {
    function mint(address _to, uint256 _amount)  public returns (bool);
}

contract DragonFightGC is Pausable {
//    using SafeMath for uint256;
    Mutagen public mutagenContract;
    DragonETH public mainContract;
    DragonFight public dragonFightContract;
    DragonStats public dragonStatsContract;
    address wallet;
    uint256 public minFightWaitBloc = 80; //~20 min
    uint256 public maxFightWaitBloc = 172800; //~30 days??????
    uint256 public mutagenToWin = 10;
    uint256 public mutagenToLose =1;
    uint256 public mutagenToDeathWin = 100;
    
    function changeAddressMutagenContract(address _newAddress) external onlyOwner {
        mutagenContract = Mutagen(_newAddress);
    }
    function changeAddressMainContract(address _newAddress) external onlyOwner {
        mainContract = DragonETH(_newAddress);
    }
    function changeAddressFightContract(address _newAddress) external onlyOwner {
        dragonFightContract = DragonFight(_newAddress);
    }
    function changeAddressStatsContract(address _newAddress) external onlyOwner {
        dragonStatsContract = DragonStats(_newAddress);
    }
    function changeWallet(address _wallet) external onlyOwner {
        wallet = _wallet;
    }

    function changeMinFightWaitBloc(uint256 _minFightWaitBloc) external onlyOwner {
        minFightWaitBloc = _minFightWaitBloc;
    }

    function changeMaxFightWaitBloc(uint256 _maxFightWaitBloc) external onlyOwner {
        maxFightWaitBloc = _maxFightWaitBloc;
    }
    
    function changeMutagenToWin(uint256 _mutagenToWin) external onlyOwner {
        mutagenToWin = _mutagenToWin;
    }
    
    function changeMutagenToLose(uint256 _mutagenToLose) external onlyOwner {
        mutagenToLose = _mutagenToLose;
    }
    
    function changeMutagenToDeathWin(uint256 _mutagenToDeathWin) external onlyOwner {
        mutagenToDeathWin = _mutagenToDeathWin;
    }
}