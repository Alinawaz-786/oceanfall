// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IFeatureControl is IAccessControl {
	function setFeature(bytes32 feature, bool enabled) external;
	function isEnabled(bytes32 feature) external view returns(bool);
}

contract FeatureControl is IFeatureControl, AccessControl {

	modifier withFeature(bytes32 _feature) {
		require(hasRole(_feature, address(this)), "FeatureControl.withFeature: feature disabled");
		_;
	}

	/**
	 * @inheritdoc IERC165
	 * @param interfaceId : interface ID user wants to check
	 * @return true if contract supports given interface id else false
	 */
	function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
		 //reconstruct from current interface and super interface
		return interfaceId == type(IFeatureControl).interfaceId || super.supportsInterface(interfaceId);
	}

	/**
	 * @param _feature a feature to enable/disable
	 * @param _enabled: true: enable, false: disable
	 * @notice Removes the feature from the set of the globally enabled features
	 * @dev Requires transaction sender to have a permission to set the feature requested
	 */
	function setFeature(bytes32 _feature, bool _enabled) public override {
		if(_enabled) {
			grantRole(_feature, address(this));
		} else {
			revokeRole(_feature, address(this));
		}
	}

	/**
	 * @notice Checks if requested feature is enabled globally on the contract
	 * @param _feature the feature to check
	 * @return true if the feature requested is enabled, false otherwise
	 */
	function isEnabled(bytes32 _feature) public override view returns(bool) {
		return hasRole(_feature, address(this));
	}
}
