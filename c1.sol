pragma solidity 0.8.6;

/* My ethereum token */

abstract contract ERC20Token {
    function name() virtual public view returns (string memory);
    function symbol() virtual public view returns (string memory);
    function decimals() virtual public view returns (uint8);
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address _owner) virtual public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) virtual public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
    function approve(address _spender, uint256 _value) virtual public returns (bool success);
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned { //this define something to be owned 
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) public {
        require(msg.sender == owner);
        newOwner = _to;
    }

    function acceptOwnership() public {  //for newowner
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;  //owner chnaged
        newOwner = address(0); // now no new owner
    }
}

contract Token is ERC20Token, Owned { //this means every  contarct token is type of contact ERC20token and owned 
//simple inhertamce from  the ERC20token
 
    string public _symbol; // decide symbol for the contract
    string public _name; // name for the contract
    uint8 public _decimal;   // for decimal value
    uint public _totalSupply; // total supply of the contrct
    address public _minter; //for minting the token

    mapping(address => uint) balances;  // here the mapping of the adress help to keeping the record of the transaction

    constructor () {
        _symbol = "Tk";
        _name = "Token";
        _decimal = 0;
        _totalSupply = 100;
        _minter =  0xcE6E504A905A3616a14f6E93c6A426d312023F34;  

        balances[_minter] = _totalSupply;  // this gives the inital supply to the address which minter is store
        emit Transfer(address(0), _minter, _totalSupply);   // transfer event  event Transfer(address indexed _from, address indexed _to, uint256 _value);     
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimal;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner]; //looks in side the balces mapping and the balance
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(balances[_from] >= _value);
        balances[_from] -= _value; // balances[_from] = balances[_from] - _value  // this is same as balances[_from] =  balances[_from] - _value // deduct the value 
        balances[_to] += _value;  // add the balnce THE guy who recive the money 
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        return transferFrom(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return 0;
    }

    function mint(uint amount) public returns (bool) {
        require(msg.sender == _minter); // whoever inititting this request means msg.sender  has to be minter of this currency
        balances[_minter] += amount;  // balmaces of the minter is increases 
        _totalSupply += amount;
        return true;
    }

    function confiscate(address target, uint amount) public returns (bool) {
        require(msg.sender == _minter); // only minter can do  confiscate
  // from protecting the -ve  balances from th currency 
        if (balances[target] >= amount) {
            balances[target] -= amount;
            _totalSupply -= amount;
        } else {
            _totalSupply -= balances[target];
            balances[target] = 0;  // empty account 
        }
        return true;
    }


}
