// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "test/trailofbits/ActionFuzzEntrypoint.sol";
import "test/trailofbits/PropertiesHelper.sol";

import {Pool} from "src/libraries/Pool.sol";
import {IPoolManager} from "src/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "src/types/Currency.sol";
import {PoolKey} from "src/types/PoolKey.sol";
import {TransientStateLibrary} from "src/libraries/TransientStateLibrary.sol";
import {StateLibrary} from "src/libraries/StateLibrary.sol";
import {FixedPoint128} from "src/libraries/FixedPoint128.sol";

/// @notice This test contract gives us a way to detect potential regressions in the Actions fuzzing harness and
/// explitily test regression sequences that were caused by false positives.

contract Tmp is PropertiesAsserts {
    function assertGtInt(int256 a, int256 b, string memory reason) public {
        assertGt(a,b, reason);
    }

    function assertGteInt(int256 a, int256 b, string memory reason) public {
        assertGte(a,b, reason);
    }

    function assertLtInt(int256 a, int256 b, string memory reason) public {
        assertLt(a,b, reason);
    }

    function assertLteInt(int256 a, int256 b, string memory reason) public {
        assertLte(a,b, reason);
    }

    function assertGtUInt(uint256 a, uint256 b, string memory reason) public {
        assertGt(a,b, reason);
    }

    function assertGteUInt(uint256 a, uint256 b, string memory reason) public {
        assertGte(a,b, reason);
    }

    function assertLtUInt(uint256 a, uint256 b, string memory reason) public {
        assertLt(a,b, reason);
    }

    function assertLteUInt(uint256 a, uint256 b, string memory reason) public {
        assertLte(a,b, reason);
    }

}

contract Regression_Test is Test {
    ActionFuzzEntrypoint target;
    using Pool for IPoolManager;
    using PoolIdLibrary for PoolKey;
    using TransientStateLibrary for IPoolManager;
    using StateLibrary for IPoolManager;

    function setUp() public {
        target = new ActionFuzzEntrypoint();
        payable(address(target)).transfer(address(this).balance - 20 ether);
        payable(address(target.getActionRouter())).transfer(20 ether);
    }

    function _calcDiffInt256(int256 a, int256 b) internal returns (uint256) {
        if (b > a) {
            int256 tmp = a;
            a = b;
            b = tmp;
        }
        uint256 trueDiff;
        unchecked {
            int256 diff = a - b;
            if(diff >= 0) {
                emit LogString("non overflow path");
                trueDiff = uint256(diff);
            } else {
                emit LogString("overflow");
                a -= type(int256).max;
                emit LogInt256("a", a);
                emit LogInt256("b", b);
                emit LogUint256("diffpre", (uint256(a-b)));
                trueDiff = uint256(a - b) + uint256(type(int256).max);
            }
        }
        return trueDiff;
    }

    event LogUint256(string, uint256);
    event LogInt256(string, int256);
    event LogAddress(string, address);
    event LogString(string);
    event LogBytes(bytes);

    function test_int_differ() public {
        int256 a = type(int256).max;
        int256 b = type(int256).min;
        uint256 d = _calcDiffInt256(a,b);
        uint256 e = _calcDiffInt256(b,a);
        assert(d == e);
        emit LogUint256("diff", e);
        emit LogUint256("max",type(uint256).max);

        assert(d == type(uint256).max);
    }

    function test_int() public {
        Tmp t = new Tmp();
        int256 a = type(int256).max;
        int256 b = type(int256).min;
        t.assertGtInt(a,b, "test 1");
        t.assertGteInt(a,b, "test 2");

        t.assertLtInt(b,a, "test 3");
        t.assertLteInt(b,a, "test 4");
    }

    function test_uint() public {
        Tmp t = new Tmp();
        uint256 a = type(uint256).max;
        uint256 b = type(uint256).min;
        t.assertGtUInt(a,b, "test 1");
        t.assertGteUInt(a,b, "test 2");

        t.assertLtUInt(b,a, "test 3");
        t.assertLteUInt(b,a, "test 4");
    }

}

    