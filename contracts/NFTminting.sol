// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintingEventNFTs is ERC1155, Ownable, Pausable, ERC1155Supply {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Event {
        uint256 id;
        address creatorAddress;
        uint128 maxSupply;
        string eventName;
        string dateTime;
        string description;
        string imageURL;
    }

    struct Organizer {
        address orgAddress;
        string orgDescription;
        uint256[] eventIds;
    }

    struct EventNFTminted {
        uint128 minted;
    }

    struct Minted {
        address minterAddress;
        uint256[] eventIds;
        string[] eventDetails;
    }

    address[] organizerAddress;

    mapping(address => Organizer) public Organizers;
    mapping(uint256 => Event) public Events;
    mapping(uint256 => EventNFTminted) public MintedCount;
    mapping(address => Minted) MintedEvents;

    constructor() ERC1155("Event NFTs") {
        console.log("Event NFTs contract deployed.");
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getOrganizerEventIds(address account) public view returns (uint256[] memory) {
        console.log("%s 's event ids", account);
        for(uint i = 0; i < Organizers[account].eventIds.length; i++) {
            console.log('');
        }
        return Organizers[account].eventIds;
    }

    function getMintDetails(address account) public view returns(Minted memory) {
        // Minted memory temp = new Minted;

        return MintedEvents[account];
    }

    function addOrganizer(address account, string memory desciption) public onlyOwner returns (uint8){
        for(uint256 i = 0; i < organizerAddress.length; i++) {
            if (organizerAddress[i] == account) {
                return 0;
            }
        }

        Organizers[account].orgAddress = account;
        Organizers[account].orgDescription = desciption;
        organizerAddress.push(account);
        return 1;
    }

    function createEvent(uint128 maxSupply, string memory evntName, string memory date, string memory info, string memory imageUrl ) public payable returns (uint256) {
        uint256 newTokenId = _tokenIds.current();

        Events[newTokenId].id = newTokenId;
        Events[newTokenId].creatorAddress = msg.sender;
        Events[newTokenId].maxSupply = maxSupply;
        Events[newTokenId].eventName = evntName;
        Events[newTokenId].dateTime = date;
        Events[newTokenId].description = info;
        Events[newTokenId].imageURL = imageUrl;

        Organizers[msg.sender].eventIds.push(newTokenId);

        MintedCount[newTokenId].minted = 1;

        console.log("%s CREATED by %s %d", evntName, msg.sender, newTokenId);

        _tokenIds.increment();
        return newTokenId;
    }

    // function mint(address account, uint256 id, uint256 amount, bytes memory data)
    function mint(uint256 id, int256 price, string memory seat)
        public returns(uint256)
    {
        require(MintedCount[id].minted < Events[id].maxSupply, "Minting Limit for Event Reached!");
        // _mint(account, id, amount, data);
        string memory metadata = string(abi.encodePacked('{"name": ', Events[id].eventName, '"date": ', Events[id].dateTime, '"price": ', price, '"seat": ', seat, '"mint": ', MintedCount[id].minted, '"description": ', Events[id].description, '"}"'));

        console.log(metadata);

        _mint(msg.sender, id, 1, bytes(metadata));

        MintedCount[id].minted = MintedCount[id].minted + 1;

        MintedEvents[msg.sender].minterAddress = msg.sender;
        MintedEvents[msg.sender].eventIds.push(id);
        MintedEvents[msg.sender].eventDetails.push(metadata);

        return MintedCount[id].minted;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}