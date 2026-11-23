const Expense = require("../models/expense_model");
const Group = require("../models/group_model");

const createExpense = async (expenseData) => {
    return await Expense.create(expenseData);
};

const getExpensesByGroup = async (groupId) => {
    return await Expense.find({ groupId }).sort({
        createdAt: -1,
    });
};

const getExpenseById = async (id) => {
    return await Expense.findById(id);
};

const updateExpense = async (id, data) => {
    return await Expense.findByIdAndUpdate(
        id,
        data,
        {
            new: true,
            runValidators: true,
        }
    );
};

const deleteExpense = async (id) => {
    return await Expense.findByIdAndDelete(id);
};

const recordSettlement = async ({ groupId, from, to, amount, notes }) => {
    const settlementExpense = await Expense.create({
        title: `Settlement: ${from} paid ${to}`,
        amount: Number(amount),
        paidBy: from,
        splitBetween: [to],
        notes: notes || `Settlement from ${from} to ${to}`,
        groupId,
        isSettlement: true,
    });
    return settlementExpense;
};

const calculateGroupBalances = async (groupId) => {
    const group = await Group.findById(groupId);
    if (!group) {
        throw new Error("Group not found");
    }

    const expenses = await Expense.find({ groupId });

    // Initialize stats map for all registered group members
    const memberStats = {};
    for (const member of group.members) {
        memberStats[member.name] = {
            name: member.name,
            totalPaid: 0,
            totalOwed: 0,
            netBalance: 0,
        };
    }

    let totalGroupSpending = 0;

    for (const exp of expenses) {
        const amount = Number(exp.amount) || 0;
        const payer = exp.paidBy;
        const splitList = exp.splitBetween || [];

        // Ensure payer exists in memberStats
        if (!memberStats[payer]) {
            memberStats[payer] = {
                name: payer,
                totalPaid: 0,
                totalOwed: 0,
                netBalance: 0,
            };
        }

        // Only add to group spending if it is an actual expense, not a debt settlement
        if (!exp.isSettlement) {
            totalGroupSpending += amount;
        }

        memberStats[payer].totalPaid += amount;

        if (splitList.length > 0) {
            const splitAmount = amount / splitList.length;
            for (const person of splitList) {
                if (!memberStats[person]) {
                    memberStats[person] = {
                        name: person,
                        totalPaid: 0,
                        totalOwed: 0,
                        netBalance: 0,
                    };
                }
                memberStats[person].totalOwed += splitAmount;
            }
        }
    }

    // Compute net balances: positive means they are owed, negative means they owe
    const balances = Object.values(memberStats).map((m) => {
        const net = Math.round((m.totalPaid - m.totalOwed) * 100) / 100;
        return {
            name: m.name,
            totalPaid: Math.round(m.totalPaid * 100) / 100,
            totalOwed: Math.round(m.totalOwed * 100) / 100,
            netBalance: Object.is(net, -0) ? 0 : net,
        };
    });

    // Simplify debts using greedy netting algorithm
    const debtors = [];
    const creditors = [];

    for (const b of balances) {
        if (b.netBalance < -0.009) {
            debtors.push({ name: b.name, amount: Math.abs(b.netBalance) });
        } else if (b.netBalance > 0.009) {
            creditors.push({ name: b.name, amount: b.netBalance });
        }
    }

    debtors.sort((a, b) => b.amount - a.amount);
    creditors.sort((a, b) => b.amount - a.amount);

    const settlements = [];
    let i = 0;
    let j = 0;

    while (i < debtors.length && j < creditors.length) {
        const debtor = debtors[i];
        const creditor = creditors[j];

        const settleAmount = Math.min(debtor.amount, creditor.amount);
        const roundedSettle = Math.round(settleAmount * 100) / 100;

        if (roundedSettle > 0) {
            settlements.push({
                from: debtor.name,
                to: creditor.name,
                amount: roundedSettle,
            });
        }

        debtor.amount = Math.round((debtor.amount - settleAmount) * 100) / 100;
        creditor.amount = Math.round((creditor.amount - settleAmount) * 100) / 100;

        if (debtor.amount <= 0.009) {
            i++;
        }
        if (creditor.amount <= 0.009) {
            j++;
        }
    }

    return {
        totalGroupSpending: Math.round(totalGroupSpending * 100) / 100,
        balances,
        settlements,
    };
};

module.exports = {
    createExpense,
    getExpensesByGroup,
    getExpenseById,
    updateExpense,
    deleteExpense,
    recordSettlement,
    calculateGroupBalances,
};