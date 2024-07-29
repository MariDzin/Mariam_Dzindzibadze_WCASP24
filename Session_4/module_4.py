PASSING_GRADE = 8


class Trainee:
    def __init__(self, name, surname):
        self.name = name
        self.surname = surname
        self.visited_lectures = 0
        self.done_home_tasks = 0
        self.missed_home_tasks = 0
        self.missed_lectures = 0
        self.mark = 0

    def visit_lecture(self):
        self.visited_lectures += 1
        self._add_points(1)

    # everytime visiting lecture one additional point in visiting lecture and
    # points increase by one

    def do_homework(self):
        self.done_home_tasks += 2
        self._add_points(2)

    # same here logic is same
    def miss_lecture(self):
        self.missed_lectures -= 1
        self._subtract_points(1)

    def miss_homework(self):
        self.missed_home_tasks -= 2
        self._subtract_points(2)

    def _add_points(self, points: int):
        self.mark += points

        if self.mark > 10:
            self.mark = 10

    # here making sure that mark will not be more than ten and also mark is increased
    # by points

    def _subtract_points(self, points):
        self.mark -= points

        if self.mark < 0:
            self.mark = 0

    # here mark can become below zero and also mark should decrease by points
    # in _subtract_points method
    def is_passed(self):
        if self.mark >= PASSING_GRADE:
            print('Good job!')
        else:
            print(f"You need to {(PASSING_GRADE - self.mark)} points. Try to do your best!")

    # if mark is more than seven then good job will be printed and if
    # not then I print how many points  needed to pass

    def __str__(self):
        status = (
            f"Trainee {self.name.title()} {self.surname.title()}:\n"
            f"done homework {self.done_home_tasks} points;\n"
            f"missed homework {self.missed_home_tasks} points;\n"
            f"visited lectures {self.visited_lectures} points;\n"
            f"missed lectures {self.missed_lectures} points;\n"
            f"current mark {self.mark};\n"
        )
        return status
