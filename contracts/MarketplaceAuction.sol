// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Marketplace.sol";

contract MarketplaceAuction is Marketplace {
    struct Listing {
        address lister;
        uint256 initialPrice;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(IERC721 => mapping(uint256 => Listing)) public listings;

    event Listed(address lister, IERC721 token, uint256 tokenId, uint256 initialPrice, uint256 endTime);
    event Unlisted(address lister, IERC721 token, uint256 tokenId);
    event Settled(address purchaser, address lister, IERC721 token, uint256 tokenId, uint256 endPrice);
    event Bid(address bidder, IERC721 token, uint256 tokenId, uint256 amount);

    constructor(
        IERC721[] memory _whitelistedTokens,
        IERC20 _currency,
        address _feeTo,
        uint256 _feePercentage
    ) Marketplace(_whitelistedTokens, _currency) {}

    function list(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _biddingTime
    ) public whenNotPaused onlyWhitelistedTokens(_token) {
        Listing storage listing = listings[_token][_tokenId];
        require(_token.ownerOf(_tokenId) == msg.sender, "MARKETPLACE: Caller is not token owner");
        _token.transferFrom(msg.sender, address(this), _tokenId);

        Listing memory newListing = Listing({
            lister: msg.sender,
            initialPrice: _initialPrice,
            endTime: block.timestamp + _biddingTime,
            highestBidder: msg.sender,
            highestBid: 0
        });
        listings[_token][_tokenId] = newListing;
        emit Listed(msg.sender, _token, _tokenId, _initialPrice, listing.endTime);
    }

    function bid(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _amount
    ) public whenNotPaused onlyWhitelistedTokens(_token) {
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister != address(0), "MARKETPLACE: Token not listed");
        require(listing.lister != msg.sender, "MARKETPLACE: Can't bid on your own token");
        require(block.timestamp < listing.endTime, "MARKETPLACE: Bid too late");
        require(_amount > listing.highestBid, "MARKETPLACE: Bid lower than previous bid");
        require(_amount > listing.initialPrice, "MARKETPLACE: Bid lower than initialPrice");

        if (listing.highestBid != 0) {
            currency.transferFrom(address(this), listing.highestBidder, listing.highestBid);
        }

        currency.transferFrom(msg.sender, address(this), _amount);

        listing.highestBid = _amount;
        listing.highestBidder = msg.sender;

        emit Bid(msg.sender, _token, _tokenId, _amount);
    }

    function settle(IERC721 _token, uint256 _tokenId) public whenNotPaused {
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister != address(0), "MARKETPLACE: Token not listed");
        require(listing.lister == msg.sender, "MARKETPLACE: Can settle only your own token");
        require(block.timestamp > listing.endTime, "MARKETPLACE: endTime not reached");

        uint256 endPrice = listing.highestBid;

        currency.transfer(listing.lister, endPrice);
        _token.transferFrom(address(this), listing.highestBidder, _tokenId);

        _unlist(_token, _tokenId);
        emit Settled(listing.highestBidder, listing.lister, _token, _tokenId, endPrice);
    }

    function withdrawTo(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20(_token).transfer(_to, _amount);
    }

    function _unlist(IERC721 _token, uint256 _tokenId) internal {
        delete listings[_token][_tokenId];
        emit Unlisted(msg.sender, _token, _tokenId);
    }
}
