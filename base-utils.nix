{ lib, nodes ? null }:

with lib;

let
  mkName = digits: index: name:
    name + (fixedWidthNumber digits index);
  getSwarmNames = digits: first: lastex: name:
    map (index: mkName digits index name) (lists.range first (lastex - 1));
  getSwarm' = nodes: digits: first: lastex: name:
    attrsets.genAttrs (getSwarmNames digits first lastex name) (n: getAttr n nodes);
  getSwarm = if nodes == null then null else getSwarm' nodes;

in {
  inherit mkName getSwarmNames getSwarm getSwarm';
}