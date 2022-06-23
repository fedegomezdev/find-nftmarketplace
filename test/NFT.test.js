const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CollectionNFT", function () {
  let owner, addr1, NFTContract;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    const NFTFactory = await ethers.getContractFactory("CollectionNFT");
    NFTContract = await NFTFactory.deploy();
  });

  describe("When deployed", function () {
    it("owner must be set correctly", async function () {
      expect(await NFTContract.owner()).to.equal(owner.address);
    });
  });

  describe("When minting", function () {
    it("New token goes for the right address", async function () {
      await NFTContract.mintNFTs(1);
      expect(await NFTContract.ownerOf(1)).to.equal(addr1.address);
    });

    it("Other addresses cannot mint", async function () {
      expect(NFTContract.connect(addr1).mint(addr1.address, "mockmetadataurl.com", mockMetadata)).to.be.revertedWith(
        "'Ownable: caller is not the owner"
      );
    });

    it("Emit metadata event", async function () {
      await expect(NFTContract.mint(addr1.address, "mockmetadataurl.com", mockMetadata))
        .to.emit(NFTContract, "Metadata")
        .withArgs(1, mockMetadata);
    });

    it("Save metadata url", async function () {
      await NFTContract.mint(addr1.address, "mockmetadataurl.com", mockMetadata);
      expect(await NFTContract.tokenURI(1)).to.equal("mockmetadataurl.com");
    });

    it("Change the contract Ownership", async function () {
      await NFTContract.connect(owner).transferOwnership(addr1.address);
      expect(await NFTContract.owner()).to.equal(addr1.address);
    });
  });
});
