# Active Power Automate Contracts

This directory contains stable interface contracts for active PULSE flows when those contracts are useful independently from the exported flow definition.

Contract documentation must be grounded in the real flow and its real callers. At minimum, record the flow name, purpose, callers, input order/types, response shape, error semantics and relevant backend dependencies when known.

Do not use this directory to invent missing flow behavior. When the real flow definition has not yet been captured, mark the contract as partial and identify the execution environment as the remaining authority.
