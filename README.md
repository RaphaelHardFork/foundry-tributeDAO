# Implementation of TributeDAO with Foundry

_The code is simplified as it doesn't use the deployment process proposed by [TributeDAO](https://tributedao.com/docs/intro/overview-and-benefits/)_

## Removed code

src/core/DaoRegistry.sol:386:

```js
function addExtension(
    bytes32,
    IExtension,
    address
) external {
    revert("not implemented");
}
```

## Deployment process
