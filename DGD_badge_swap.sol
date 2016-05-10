// Version 0.1
// This swap contract was created by Attores and released under a GPL license
// Visit attores.com for more contracts and Smart contract as a Service 

// This is the interface of the badge contract
contract Badge{
function Badge();
function approve(address _spender,uint256 _value)returns(bool success);
function setOwner(address _owner)returns(bool success);
function totalSupply()constant returns(uint256 );
function transferFrom(address _from,address _to,uint256 _value)returns(bool success);
function subtractSafely(uint256 a,uint256 b)returns(uint256 );
function mint(address _owner,uint256 _amount)returns(bool success);
function safeToAdd(uint256 a,uint256 b)returns(bool );
function balanceOf(address _owner)constant returns(uint256 balance);
function owner()constant returns(address );
function transfer(address _to,uint256 _value)returns(bool success);
function addSafely(uint256 a,uint256 b)returns(uint256 result);
function locked()constant returns(bool );
function allowance(address _owner,address _spender)constant returns(uint256 remaining);
function safeToSubtract(uint256 a,uint256 b)returns(bool );
}

// Actual swap contract written by Attores
contract swap{
    address public beneficiary;
    Badge public badgeObj;
    uint public price_token;
    uint256 public WEI_PER_FINNEY = 1000000000000000;
    uint public expiryDate;
    
    // Constructor function for this contract. Called during contract creation
    function swap(address sendEtherTo, address adddressOfBadge, uint badgePriceInFinney_1000FinneyIs_1Ether, uint durationInDays){
        beneficiary = sendEtherTo;
        badgeObj = Badge(adddressOfBadge);
        price_token = badgePriceInFinney_1000FinneyIs_1Ether * WEI_PER_FINNEY;
        expiryDate = now + durationInDays * 1 days;
    }
    
    // This function is called every time some one sends ether to this contract
    function(){
        if (now >= expiryDate) throw;
        var badges_to_send = msg.value / price_token;
        uint balance = badgeObj.balanceOf(this);
        address payee = msg.sender;
        if (balance >= badges_to_send){
            badgeObj.transfer(msg.sender, badges_to_send);
            beneficiary.send(msg.value);    
        } else {
            badgeObj.transfer(msg.sender, balance);
            uint amountReturned = (badges_to_send - balance) * price_token;
            payee.send(amountReturned);
            beneficiary.send(msg.value - amountReturned);
        }
    }
    
    modifier afterExpiry() { if (now >= expiryDate) _ }
    
    //This function checks if the expiry date has passed and if it has, then returns the tokens to the beneficiary
    function checkExpiry() afterExpiry{
        uint balance = badgeObj.balanceOf(this);
        badgeObj.transfer(beneficiary, balance);
    }
}

