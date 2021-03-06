pragma solidity ^0.4.24;

import "../security/rbac/RBACWithAdmin.sol";

contract RNG {
function get32b(address _from, uint256 _dragonID) external returns (bytes32 b32);
}
contract GenRNG is RBACWithAdmin {

  address private addressRNG;

  constructor(address _addressRNG) public {
  addressRNG = _addressRNG;
}

function changeAddressRNG(address _addressRNG) external onlyAdmin {
  addressRNG = _addressRNG;
}

  function getNewGens(address _from, uint256 _dragonID) external onlyRole("MainContract") returns (uint256[2] resultGen) {
   bytes32 random_number;
   uint8 tmpGen;
   random_number = RNG(addressRNG).get32b(_from, _dragonID);
//00 rezerved(for color) 00h - 00h
//01 detailColorSchemaGen = 00h - ffh
    resultGen[0] += uint8(random_number[1]);
    resultGen[0] = resultGen[0] << 8;
//02*detailAuraGen = 00h - 04h
    tmpGen = uint8(random_number[2]);
    if (tmpGen >= 229) 
        if (tmpGen <= 252) 
            resultGen[0] += 1 + tmpGen % 3;
        else 
            resultGen[0] += 4;

    resultGen[0] = resultGen[0] << 8;
//03 detailAuraColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[3]) % 5;
    resultGen[0] = resultGen[0] << 8;
//04 *detailWingsGen = 00h - 05h
    tmpGen = uint8(random_number[4]);
     if (tmpGen >= 5) 
        if (tmpGen < 41) 
            resultGen[0] += 1;
        else if (tmpGen < 128)
            resultGen[0] += 2;
            else if (tmpGen < 214)
                resultGen[0] += 3;
                else if (tmpGen < 250)
                    resultGen[0] += 4;
                    else 
                        resultGen[0] += 5;
    

    resultGen[0] = resultGen[0] << 16;
//05 reserved
//    resultGen[0] = resultGen[0] + uint8(random_number[5]) % 5;
//    resultGen[0] = resultGen[0] << 8;
//06 detailWingsColor2Gen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[6]) % 5;
    resultGen[0] = resultGen[0] << 8;
//07 *detailTailGen = 00h - 07h
    //resultGen[0] = resultGen[0] + uint8(random_number[7]) % 8;
    tmpGen = uint8(random_number[7]);
    if (tmpGen < 10) 
        resultGen[0] += tmpGen % 2;
    else if (tmpGen < 184)
            resultGen[0] += 2 + tmpGen % 2;
        else 
            resultGen[0] += 4 + tmpGen % 4;

    resultGen[0] = resultGen[0] << 16;

//08 reserved
//    resultGen[0] = resultGen[0] + uint8(random_number[8]) % 5;
    //resultGen[0] = resultGen[0] << 8;
//09 detailTailColor2Gen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[9]) % 5;
    resultGen[0] = resultGen[0] << 8;
//10 +detailBodyGen = 00h - 02h
    //resultGen[0] = resultGen[0] + uint8(random_number[10]) % 5;
    tmpGen = uint8(random_number[10]);
    if (tmpGen > 153)
        if (tmpGen < 204) 
            resultGen[0] += 1;
        else 
            resultGen[0] += 2;
                
    resultGen[0] = resultGen[0] << 8;
//11 detailBodyColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[11]) % 5;
    resultGen[0] = resultGen[0] << 8;
//12 *detailSpotsGen = 00h - 09h
    //resultGen[0] = resultGen[0] + uint8(random_number[12]) % 10;
    tmpGen = uint8(random_number[12]);
    if (tmpGen >= 102) 
        if (tmpGen < 194) 
            resultGen[0] += 1 + tmpGen % 2;
        else if (tmpGen < 240)
            resultGen[0] += 3 + tmpGen % 3;
            else 
                resultGen[0] += 6 + tmpGen % 4;

    resultGen[0] = resultGen[0] << 8;
//13 detailSpotsColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[13]) % 5;
    resultGen[0] = resultGen[0] << 8;
//14 *detailScalesGen = 00h - 04h
    tmpGen = uint8(random_number[14]);
    if (tmpGen >= 178) // 255 * 0.4 ~ 102
        if (tmpGen < 224) 
            resultGen[0] += 1;
        else if (tmpGen < 247)
            resultGen[0] += 2;
            else if (tmpGen < 251)
                resultGen[0] += 3;
                else
                    resultGen[0] += 4;
    resultGen[0] = resultGen[0] << 8;
//15 detailScalesColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[15]) % 5;
    resultGen[0] = resultGen[0] << 8;
//16 *detailHornsGen = 00h - 07h
    tmpGen = uint8(random_number[16]);
    if (tmpGen >= 102) 
        if (tmpGen < 194) 
            resultGen[0] += 1 + tmpGen % 2;
        else if (tmpGen < 240)
            resultGen[0] += 3 + tmpGen % 2;
            else 
                resultGen[0] += 5 + tmpGen % 3;

    resultGen[0] = resultGen[0] << 8;
//17 detailHornsColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[17]) % 5;
    resultGen[0] = resultGen[0] << 8;
//18 +detailHeadGen = 00h - 05h
    tmpGen = uint8(random_number[18]);
    if (tmpGen >= 153) 
        if (tmpGen < 192) 
            resultGen[0] += 1;
        else if (tmpGen < 230)
            resultGen[0] += 2;
            else if (tmpGen < 243)
                resultGen[0] += 3;
                else
                    resultGen[0] += 4;
    resultGen[0] = resultGen[0] << 16;
//19 reserved
//    resultGen[0] = resultGen[0] + uint8(random_number[19]) % 5;
//    resultGen[0] = resultGen[0] << 8;
//20 mutagenImutable 00h-FFh
    resultGen[0] = resultGen[0] + uint8(random_number[20]);
    resultGen[0] = resultGen[0] << 24;
//21 +detailPawsGen = 00h
//    resultGen[0] = resultGen[0] + uint8(random_number[21]) % 5;
//    resultGen[0] = resultGen[0] << 8;
//22 reserved
//    resultGen[0] = resultGen[0] + uint8(random_number[22]) % 5;
//    resultGen[0] = resultGen[0] << 8;
//23 detailClawsColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[23]) % 5;
    resultGen[0] = resultGen[0] << 8;
//24 +detailEyesGen = 00h - 04h
    tmpGen = uint8(random_number[24]);
     if (tmpGen < 10) 
        resultGen[0] += tmpGen % 2;
    else if (tmpGen < 163)
            resultGen[0] += 2 + tmpGen % 2;
        else if (tmpGen < 204)
                resultGen[0] += 4 + tmpGen % 2;
            else if (tmpGen < 235)
                resultGen[0] += 6 + tmpGen % 2;
                else
                    resultGen[0] += 8 + tmpGen % 2;
    resultGen[0] = resultGen[0] << 8;
//25 detailEyesColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[25]) % 5;
    resultGen[0] = resultGen[0] << 8; 
//26 *detailSpinsGen = 00h - 04h
    tmpGen = uint8(random_number[26]);
    if (tmpGen >= 140) 
        if (tmpGen < 209) 
            resultGen[0] += 1;
        else if (tmpGen < 243)
            resultGen[0] += 2;
            else if (tmpGen < 249)
                resultGen[0] += 3;
                else
                    resultGen[0] += 4;
    resultGen[0] = resultGen[0] << 8;
//27 detailSpinsColorGen = 00h - 04h
    resultGen[0] = resultGen[0] + uint8(random_number[27]) % 5;
    resultGen[0] = resultGen[0] << 32;
//28 reserved
//    resultGen[0] = resultGen[0] + uint8(random_number[28]) % 5;
//    resultGen[0] = resultGen[0] << 8;
//29 reserved
//    resultGen[0] = resultGen[0] + uint8(random_number[29]) % 5;
//    resultGen[0] = resultGen[0] << 8;
//30 rezerved 00h - 00h
//31 rezerved 00h - 00h


//    resultGen[0] = resultGen[0] << 8;
    resultGen[1] = uint256(RNG(addressRNG).get32b(_from, _dragonID));
  }
}
