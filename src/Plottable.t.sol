// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.13;

import { Vm } from "forge-std/Vm.sol";
import { DSTest } from "ds-test/test.sol";
import { Trigonometry } from "solidity-trigonometry/Trigonometry.sol";

contract Plottable is DSTest {
  bytes16 internal constant HEX_SYMBOLS = "0123456789abcdef";
  Vm internal constant VM = Vm(HEVM_ADDRESS);

  function testTrigonometrySin(uint256 angle) external returns (int256 sin, int256 epsilon) {
    string[] memory ffi = new string[](2);
    ffi[0] = "ffi/sin";
    ffi[1] = encodeHex(abi.encode(angle));
    int256 refSin = abi.decode(VM.ffi(ffi), (int256));

    sin = Trigonometry.sin(angle);
    epsilon = sin - refSin;

    assertApproxEq(sin, refSin, 5e12);
  }

  function encodeHex(bytes memory raw) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * raw.length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 0; i < raw.length; i++) {
      buffer[2 * i + 2] = HEX_SYMBOLS[(uint8(raw[i]) >> 4) & 0xf];
      buffer[2 * i + 3] = HEX_SYMBOLS[uint8(raw[i]) & 0xf];
    }
    return string(buffer);
  }

  function assertApproxEq(
    int256 a,
    int256 b,
    uint256 maxDelta
  ) internal virtual {
    uint256 delta = uint256(a > b ? a - b : b - a);

    if (delta > maxDelta) {
      emit log("Error: a ~= b not satisfied [uint]");
      emit log_named_int("   Expected", b);
      emit log_named_int("     Actual", a);
      emit log_named_uint(" Max Delta", maxDelta);
      emit log_named_uint("     Delta", delta);
      fail();
    }
  }
}
