import Foundation

enum UIConstants {
    static let trackerCollectionViewLabel = NSLocalizedString("UIConstants.trackerCollectionViewLabel", comment: "Трекеры")
    static let statisticsViewLabel = NSLocalizedString("UIConstants.statisticsViewLabel", comment: "Статистика")
}

enum UITrackersVCConstants {
    static let title = NSLocalizedString("UITrackersVCConstants.title", comment: "Трекеры")
    static let clearTextLabel = NSLocalizedString("UITrackersVCConstants.clearTextLabel", comment: "Что будем отслеживать?")
    static let clearTextLabelNothingWasFound = NSLocalizedString("UITrackersVCConstants.clearTextLabelNothingWasFound", comment: "Ничего не найдено")
    static let searchBarPlaceholder = NSLocalizedString("UITrackersVCConstants.searchBarPlaceholder", comment: "Поиск")
    static let filtersButtonLabel = NSLocalizedString("UITrackersVCConstants.filtersButtonLabel", comment: "Фильтры")
    static let contextEditLabel = NSLocalizedString("UITrackersVCConstants.contextEditLabel", comment: "Редактировать")
    static let contextDeleteLabel = NSLocalizedString("UITrackersVCConstants.contextDeleteLabel", comment: "Удалить")
    static let deleteTrackerTitle = NSLocalizedString("UITrackersVCConstants.deleteTrackerTitle", comment: "Это действие нельзя отменить")
    static let deleteTrackerMessage = NSLocalizedString("UITrackersVCConstants.deleteTrackerMessage", comment: "Удалить")
    static let deleteTrackerOK = NSLocalizedString("UITrackersVCConstants.deleteTrackerOK", comment: "Удалить")
    static let deleteTrackerCancel = NSLocalizedString("UITrackersVCConstants.deleteTrackerCancel", comment: "Отмена")
    
    
    static let filterButtonSize = CGSize(width: 114, height: 50)
    static let filterButtonCornerRadius: CGFloat = 16
    static let searchFieldHeight: CGFloat = 36
}

enum UIHabitTrackerConstants {
    static let errorMessage = NSLocalizedString("UIHabitTrackerConstants.errorMessage", comment: "Ограничение 38 символов")
    static let sectionCategory = NSLocalizedString("UIHabitTrackerConstants.sectionCategory", comment: "Категория")
    static let sectionSchedule = NSLocalizedString("UIHabitTrackerConstants.sectionSchedule", comment: "Расписание")
    static let categoryImportant = NSLocalizedString("UIHabitTrackerConstants.categoryImportant", comment: "Важное")
    static let categoryUnimportant = NSLocalizedString("UIHabitTrackerConstants.categoryUnimportant", comment: "Неважное")
    static let title = NSLocalizedString("UIHabitTrackerConstants.title", comment: "Новая привычка")
    static let editTitle = NSLocalizedString("UIHabitTrackerConstants.editTitle", comment: "Редактирование привычки")
    static let namePlaceholder = NSLocalizedString("UIHabitTrackerConstants.namePlaceholder", comment: "Введите название трекера")
    static let createButtonLabel = NSLocalizedString("UIHabitTrackerConstants.createButtonLabel", comment: "Создать")
    static let cancelButtonLabel = NSLocalizedString("UIHabitTrackerConstants.cancelButtonLabel", comment: "Отменить")
    static let emojiTitle = NSLocalizedString("UIHabitTrackerConstants.emojiTitle", comment: "Emoji")
    static let colorTitle = NSLocalizedString("UIHabitTrackerConstants.colorTitle", comment: "Цвет")
    static let everyDay = NSLocalizedString("UIHabitTrackerConstants.everyDay", comment: "Каждый день")
}

enum NewTrackerConstants{
    static let newTrackerTitleSymbolsLimit = 38
}

enum UIScheduleConstants {
    static let navigationTitle = NSLocalizedString("UIScheduleConstants.navigationTitle", comment: "Расписание")
    static let doneButtonTitle = NSLocalizedString("UIScheduleConstants.doneButtonTitle", comment: "Готово")
}

enum UICategoryConstants {
    static let navigationTitle = NSLocalizedString("UICategoryConstants.navigationTitle", comment: "Категория")
    static let addButtonTitle = NSLocalizedString("UICategoryConstants.addButtonTitle", comment: "Добавить категорию")
    static let clearTextLabel = NSLocalizedString("UICategoryConstants.clearTextLabel", comment: "Привычки и события можно\n объединить по смыслу")
    static let namePlaceholder = NSLocalizedString("UICategoryConstants.namePlaceholder", comment: "Введите название категории")
    static let title = NSLocalizedString("UICategoryConstants.title", comment: "Новая категория")
}

enum UUIOnboardingConstants {
    static let buttonTitle = NSLocalizedString("UUIOnboardingConstants.buttonTitle", comment: "Вот это технологии!")
    static let textOnboardingv1 = NSLocalizedString("UUIOnboardingConstants.textOnboardingv1", comment: "Отслеживайте только то, что хотите")
    static let textOnboardingv2 = NSLocalizedString("UUIOnboardingConstants.textOnboardingv2", comment: "Даже если это\nне литры воды и йога")
}

enum WeekdaysConstants {
    static let monday = NSLocalizedString("UIWeekday.monday", comment: "Понедельник")
    static let tuesday = NSLocalizedString("UIWeekday.tuesday", comment: "Вторник")
    static let wednesday = NSLocalizedString("UIWeekday.wednesday", comment: "Среда")
    static let thursday = NSLocalizedString("UIWeekday.thursday", comment: "Четверг")
    static let friday = NSLocalizedString("UIWeekday.friday", comment: "Пятница")
    static let saturday = NSLocalizedString("UIWeekday.saturday", comment: "Суббота")
    static let sunday = NSLocalizedString("UIWeekday.sunday", comment: "Воскресенье")
    
    static let m = NSLocalizedString("UIWeekday.m", comment: "Пн")
    static let tu = NSLocalizedString("UIWeekday.tu", comment: "Вт")
    static let w = NSLocalizedString("UIWeekday.w", comment: "Ср")
    static let th = NSLocalizedString("UIWeekday.th", comment: "Чт")
    static let f = NSLocalizedString("UIWeekday.f", comment: "Пт")
    static let s = NSLocalizedString("UIWeekday.s", comment: "Сб")
    static let su = NSLocalizedString("UIWeekday.su", comment: "Вс")
}

enum TrackerFilterConstants {
    static let all = NSLocalizedString("UITrackerFilter.all", comment: "Все трекеры")
    static let today = NSLocalizedString("UITrackerFilter.today", comment: "Трекеры на сегодня")
    static let completed = NSLocalizedString("UITrackerFilter.completed", comment: "Завершённые")
    static let uncompleted = NSLocalizedString("UITrackerFilter.uncompleted", comment: "Незавершённые")
    static let listTitle = NSLocalizedString("UITrackerFilter.listTitle", comment: "Фильтры")
}



enum UIStatisticsConstants {
    static let bestPeriod = NSLocalizedString("UIStatisticsConstants.bestPeriod", comment: "Лучший период")
    static let perfectDays = NSLocalizedString("UIStatisticsConstants.perfectDays", comment: "Идеальные дни")
    static let completed = NSLocalizedString("UIStatisticsConstants.completed", comment: "Трекеров завершено")
    static let average = NSLocalizedString("UIStatisticsConstants.average", comment: "Среднее значение")
    static let clearText = NSLocalizedString("UIStatisticsConstants.clearText", comment: "Анализировать пока нечего")
    static let title = NSLocalizedString("UIStatisticsConstants.title", comment: "Статистика")
}
