// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts@4.9.6/governance/Governor.sol";
import "@openzeppelin/contracts@4.9.6/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts@4.9.6/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts@4.9.6/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts@4.9.6/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts@4.9.6/governance/extensions/GovernorTimelockControl.sol";

contract DCDAO is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(IVotes _token, TimelockController _timelock)
        Governor("DCDAO")
        GovernorSettings(7200, /* 1 day */ 50400, /* 1 week */ 1)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(30)
        GovernorTimelockControl(_timelock)
    {}

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
