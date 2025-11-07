// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBeanstalk} from "contracts/interfaces/IBeanstalk.sol";

/**
 * @title MockBlueprint
 * @notice Mock blueprint contract for testing dynamic data injection with tractorWithData
 */
contract MockBlueprint {
    IBeanstalk public immutable beanstalk;

    uint256 public constant HARVEST_PLOTS_KEY = 1;
    uint256 public constant PLOT_AMOUNTS_KEY = 2;
    
    event DynamicDataUsed(uint256[] plots, uint256[] amounts);
    event HarvestSimulated(address indexed user, uint256 fieldId, uint256[] plots, uint256 totalPods);

    constructor(address _beanstalk) {
        beanstalk = IBeanstalk(_beanstalk);
    }

    /**
     * @notice Main blueprint function that uses dynamic data
     * @dev This function demonstrates how a blueprint contract can access
     * dynamic data injected via tractorWithData
     */
    function executeBlueprint() external {
        bytes memory plotData = beanstalk.getTractorData(HARVEST_PLOTS_KEY);
        require(plotData.length > 0, "No harvest plot data available");

        uint256[] memory harvestablePlots = abi.decode(plotData, (uint256[]));

        bytes memory amountData = beanstalk.getTractorData(PLOT_AMOUNTS_KEY);
        uint256[] memory plotAmounts;

        if (amountData.length > 0) {
            plotAmounts = abi.decode(amountData, (uint256[]));
            require(
                plotAmounts.length == harvestablePlots.length,
                "Plot and amount arrays must match"
            );
        }

        emit DynamicDataUsed(harvestablePlots, plotAmounts);
        _simulateHarvest(harvestablePlots);
    }

    /**
     * @notice Simulate harvest operations using dynamic data with realistic validation
     * @param plots The harvestable plots from dynamic data
     */
    function _simulateHarvest(uint256[] memory plots) internal {
        require(plots.length > 0, "MockBlueprint: No plots to harvest");
        
        address user = beanstalk.tractorUser();
        uint256 fieldId = beanstalk.activeField();
        uint256 harvestableIndex = beanstalk.harvestableIndex(fieldId);
        uint256 totalHarvestablePods;
        
        for (uint256 i; i < plots.length; ++i) {
            uint256 plotIndex = plots[i];
            uint256 plotPods = beanstalk.plot(user, fieldId, plotIndex);
            
            // Validate plot ownership (like real harvest)
            require(plotPods > 0, "MockBlueprint: no plot");
            
            // Validate harvestability (like real harvest)
            require(plotIndex < harvestableIndex, "MockBlueprint: plot not harvestable");
            
            // Calculate harvestable pods (like real harvest)
            uint256 harvestablePods = harvestableIndex - plotIndex;
            if (harvestablePods > plotPods) harvestablePods = plotPods;
            
            totalHarvestablePods += harvestablePods;
        }
        
        // Emit simulation event (like real harvest event)
        emit HarvestSimulated(user, fieldId, plots, totalHarvestablePods);
        
        // Note: We don't actually modify state, just validate and emit event
        // This simulates the harvest logic without side effects
    }

    /**
     * @notice Helper function to get current user
     * @return The current tractor user
     */
    function getCurrentUser() external view returns (address) {
        return beanstalk.tractorUser();
    }

    /**
     * @notice Helper function to check if data exists for a key
     * @param key The data key to check
     * @return True if data exists for the key
     */
    function hasDataForKey(uint256 key) external view returns (bool) {
        bytes memory data = beanstalk.getTractorData(key);
        return data.length > 0;
    }
}
