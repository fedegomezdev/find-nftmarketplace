//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Marketplace.sol";

contract MarketplaceFixedPrice is Marketplace {
    struct Listing {
        address owner;
        uint256 price;
    }

    event Listed(address owner, IERC721 token, uint256 tokenId, uint256 price);
    event Unlisted(address owner, IERC721 token, uint256 tokenId, bool purchased);
    event Purchased(address purchaser, address owner, IERC721 token, uint256 tokenId, uint256 price);

    mapping(IERC721 => mapping(uint256 => Listing)) public listings;

    constructor(
        IERC721[] memory _whitelistedTokens,
        IERC20 _currency,
        address _feeTo,
        uint256 _feePercentage
    ) Marketplace(_whitelistedTokens, _currency) {}

    function list(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _price
    ) public whenNotPaused onlyWhitelistedTokens(_token) {
        require(_token.ownerOf(_tokenId) == msg.sender, "MARKETPLACE FIXED: Caller is not token owner");
        _token.transferFrom(msg.sender, address(this), _tokenId);
        listings[_token][_tokenId] = Listing({owner: msg.sender, price: _price});
        emit Listed(msg.sender, _token, _tokenId, _price);
    }

    function unlist(IERC721 _token, uint256 _tokenId) public onlyWhitelistedTokens(_token) {
        Listing memory listing = listings[_token][_tokenId];
        require(listing.owner == msg.sender, "MARKETPLACE FIXED: Caller is not token owner");
        _unlist(_token, _tokenId, false);
        _token.transferFrom(address(this), msg.sender, _tokenId);
    }

    function purchase(IERC721 _token, uint256 tokenId) public whenNotPaused {
        Listing memory listing = listings[_token][tokenId];
        require(listing.owner != address(0), "MARKETPLACE FIXED: tokenId not for sale");

        uint256 price = listing.price;
        IERC20(currency).transferFrom(msg.sender, listing.owner, price);
        _token.transferFrom(address(this), msg.sender, tokenId);
        emit Purchased(msg.sender, listing.owner, _token, tokenId, listing.price);
        _unlist(_token, tokenId, false);
    }

    function withdrawTo(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }

    function _unlist(
        IERC721 _token,
        uint256 _tokenId,
        bool _purchased
    ) internal {
        delete listings[_token][_tokenId];
        emit Unlisted(msg.sender, _token, _tokenId, _purchased);
    }
}
