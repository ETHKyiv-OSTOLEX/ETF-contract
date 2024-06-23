pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ETFContract  {
    struct ETF  {
        uint256 price;  
        address owner_address;
        mapping(string => uint64) tokenPercentages; // 100% - 1_000_000   
    }

    address public owner;
    IERC20 public usdcToken;
    mapping(uint16 => ETF) public etfs; 
    uint16 current_id;

    constructor(address  _usdcTokenAddress) {
        owner = msg.sender;
        usdcToken = IERC20(_usdcTokenAddress);
    }

    modifier check_len(string[] memory _tokens, uint256[] memory _percentages) {
        require(_tokens.length == _percentages.length, "Tokens and percentages length mismatch.");
        _;
    }

    modifier check_price(uint256 _price) {
        require(_price > 0, "Price must be greater than 0.");
        _;
    }

    event CreateETF(uint16 indexed current_id, uint256 indexed price, address indexed owner_address, string[] tokens, uint64[] percentages);

    function create_etf(uint256 _price, string[] memory _tokens, uint64[] memory _percentages) external check_price(_price) {
        ETF storage newETF = etfs[current_id];
        newETF.price = _price;
        newETF.owner_address = msg.sender;

        for(uint256 i = 0; i < _tokens.length; i++) {
            newETF.tokenPercentages[_tokens[i]] = _percentages[i];
        }

        emit CreateETF(current_id, _price, msg.sender, _tokens, _percentages);

        current_id += 1;
    }

    modifier check_amount(uint256 _amount) {
        require(_amount > 0, "Price must be greater than 0.");
        _;
    }

    event BuyETF(uint16 indexed etf_id, uint256 indexed amount, address indexed buyer_adderess);

    function buy_etf(uint16 _etfId, uint256 _amount) external check_amount(_amount) {
        ETF storage etf = etfs[_etfId];
        emit BuyETF(_etfId, _amount, msg.sender);
        
        require(usdcToken.transferFrom(msg.sender, etf.owner_address, etf.price), "USDC transfer failed.");
    }

    event Approve(uint16 indexed etf_id, uint256 indexed amount, address indexed buyer_adderess);

    function approve(uint16 _etfId, uint256 _amount) external {
        emit Approve(_etfId, _amount, msg.sender);
    }
}
