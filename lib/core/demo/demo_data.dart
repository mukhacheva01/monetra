import '../../features/budgets/domain/budget_summary.dart';
import '../../features/categories/domain/category_item.dart';
import '../../features/transactions/domain/transaction_entry.dart';

class DemoData {
  static const categories = [
    CategoryItem(
      id: 'food',
      name: 'Еда',
      emoji: '🍜',
      colorHex: 0xFFFF8A65,
    ),
    CategoryItem(
      id: 'transport',
      name: 'Транспорт',
      emoji: '🚇',
      colorHex: 0xFF4DB6AC,
    ),
    CategoryItem(
      id: 'home',
      name: 'Дом',
      emoji: '🏠',
      colorHex: 0xFF9575CD,
    ),
    CategoryItem(
      id: 'health',
      name: 'Здоровье',
      emoji: '💊',
      colorHex: 0xFF64B5F6,
    ),
    CategoryItem(
      id: 'salary',
      name: 'Доход',
      emoji: '💼',
      colorHex: 0xFF81C784,
    ),
  ];

  static final transactions = [
    TransactionEntry(
      id: 'tx_1',
      amount: 890,
      type: TransactionType.expense,
      categoryId: 'food',
      createdAt: DateTime(2026, 6, 3, 8, 42),
      note: 'Завтрак и кофе',
    ),
    TransactionEntry(
      id: 'tx_2',
      amount: 1250,
      type: TransactionType.expense,
      categoryId: 'transport',
      createdAt: DateTime(2026, 6, 2, 19, 10),
      note: 'Такси после встречи',
    ),
    TransactionEntry(
      id: 'tx_3',
      amount: 3200,
      type: TransactionType.expense,
      categoryId: 'home',
      createdAt: DateTime(2026, 6, 2, 12, 15),
      note: 'Товары для дома',
    ),
    TransactionEntry(
      id: 'tx_4',
      amount: 54000,
      type: TransactionType.income,
      categoryId: 'salary',
      createdAt: DateTime(2026, 6, 1, 9, 0),
      note: 'Зарплата',
    ),
    TransactionEntry(
      id: 'tx_5',
      amount: 1600,
      type: TransactionType.expense,
      categoryId: 'health',
      createdAt: DateTime(2026, 5, 31, 18, 20),
      note: 'Аптека',
    ),
  ];

  static const budgets = [
    BudgetSummary(
      categoryId: 'food',
      title: 'Еда',
      spent: 12400,
      limit: 18000,
    ),
    BudgetSummary(
      categoryId: 'transport',
      title: 'Транспорт',
      spent: 5100,
      limit: 7000,
    ),
    BudgetSummary(
      categoryId: 'home',
      title: 'Дом',
      spent: 8200,
      limit: 10000,
    ),
  ];
}
