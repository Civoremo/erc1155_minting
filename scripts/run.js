const main = async () => {
  const [owner, rand1, rand2, rand3] = await hre.ethers.getSigners();
  const nftMintingContractFactory = await hre.ethers.getContractFactory(
    "MintingEventNFTs",
  );
  const nftMintingContract = await nftMintingContractFactory.deploy();
  await nftMintingContract.deployed();
  console.log("Contract deployed to: ", nftMintingContract.address);
  console.log("Deployed by:", owner.address);

  let txn = await nftMintingContract.addOrganizer(
    rand1.address,
    "This is our First Organizer Registration; Fun House Party Central",
  );

  txn = await nftMintingContract
    .connect(rand1)
    .createEvent(
      25,
      "First Event",
      "March 10, 2022 7pm",
      "This is the event of the year. FUN FUN FUN",
      "https://media.giphy.com/media/kHmVOy84g8G6my09fu/giphy.gif",
    );
  await txn.wait();

  txn = await nftMintingContract
    .connect(rand2)
    .createEvent(
      25,
      "Second Event",
      "April 1, 2022 4pm",
      "Party for the ages.",
      "https://media.giphy.com/media/blSTtZehjAZ8I/giphy.gif",
    );
  await txn.wait();

  txn = await nftMintingContract
    .connect(rand1)
    .createEvent(
      25,
      "Third Event",
      "July 21, 2022 11am",
      "Fun in the SUN.",
      "https://media.giphy.com/media/4KFa2g3LXpPV9et7NT/giphy.gif",
    );
  await txn.wait();

  console.log("\n\n-----------------------");
  console.log(
    await nftMintingContract.Organizers(rand1.address),
    "\n-----------------------\n",
  );

  txn = await nftMintingContract.getOrganizerEventIds(rand1.address);
  console.log("Event IDS from org ", rand1.address, txn);

  for (let i = 0; i < txn.length; i++) {
    console.log("Event ID", Number(txn[i]));
    console.log(`EVENT\n`, await nftMintingContract.Events(Number(txn[i])));
  }

  txn = await nftMintingContract.mint(2, 50, "A23");
  await txn.wait();
  txn = await nftMintingContract.mint(2, 50, "A24");
  await txn.wait();

  txn = await nftMintingContract.connect(rand3).mint(0, 20, "G2");
  await txn.wait();
  txn = await nftMintingContract.connect(rand1).mint(0, 25, "J15");
  await txn.wait();

  console.log(
    `${owner.address} owner of `,
    await nftMintingContract.balanceOf(owner.address, 2),
    " NFTs with ID 2\n",
  );
  console.log(
    `${rand1.address} owner of `,
    await nftMintingContract.balanceOf(rand1.address, 0),
    " NFTs with ID 0\n",
  );
  console.log(
    `${rand3.address} owner of `,
    await nftMintingContract.balanceOf(rand3.address, 0),
    " NFTs with ID 0\n",
  );

  console.log("\n\n------------------------");
  // console.log(`User minted events`, owner.address);
  console.log(await nftMintingContract.getMintDetails(owner.address));
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
